extends Node2D

## Core loop, ported from prototype/app.js's startGame/gameLoop/moveAndCollide.
## Design-space canvas is 450x800 (matches the prototype's #app-container
## max-width: 450px), so distance/size constants below are carried over
## unscaled from the original CSS/JS values.

signal run_finished(distance: int, crystals_collected: int)

const CANVAS_WIDTH := 450.0
const CANVAS_HEIGHT := 800.0
const PLAYER_Y := CANVAS_HEIGHT - 180.0
const SPRING_LERP := 0.18
const MIN_WIDTH := 10.0
const MAX_WIDTH := 140.0
const SPHERE_RADIUS := 10.0
const OBSTACLE_HALF_HEIGHT := 12.5
const CENTER_OBSTACLE_WIDTH := 60.0
const SIDE_OBSTACLE_WIDTH := 100.0
const CRYSTAL_COLLECT_DIST := 25.0
const GRAZE_BAND := 22.0
const CENTER_MERGE_THRESHOLD := 35.0
const SIDE_SAFE_MARGIN := 110.0

# Difficulty ramp: speed and spawn rate scale with score, maxing out around
# DIFFICULTY_RAMP_SCORE (score/5 = meters, so ~240m). The original prototype
# never scaled either of these — constant difficulty was a real weakness,
# not something faithfully preserved on purpose.
const BASE_SPEED := 5.0
const MAX_SPEED := 11.0
const DIFFICULTY_RAMP_SCORE := 1200.0
const BASE_SPAWN_MIN := 50.0
const BASE_SPAWN_MAX := 90.0
const HARD_SPAWN_MIN := 30.0
const HARD_SPAWN_MAX := 55.0

# Combo: grazing keeps it up and it directly multiplies score gain (real
# risk/reward now, instead of a cosmetic number); left alone for a few
# seconds, it decays back toward 1x.
const COMBO_DECAY_DELAY := 3.0
const COMBO_DECAY_RATE := 0.15

const COLOR_GREEN := Color("#39ff14")
const COLOR_BG := Color(0.012, 0.012, 0.027)

# Ported from prototype/app.js's setNeonColors()/applySkinStyles() — colorblind
# mode (if set) overrides the active tether skin, matching the original.
const SKIN_COLORS := {
	"default": {"cyan": "#00f0ff", "magenta": "#ff007f"},
	"laser": {"cyan": "#00f0ff", "magenta": "#ff003c"},
	"plasma": {"cyan": "#00ffaa", "magenta": "#ff007f"},
	"rainbow": {"cyan": "#ff00ff", "magenta": "#00ffff"},
}
const COLORBLIND_COLORS := {
	"protan": {"cyan": "#0055ff", "magenta": "#ffaa00"},
	"deuteran": {"cyan": "#00aaff", "magenta": "#ffdd00"},
}

var _cyan := Color("#00f0ff")
var _magenta := Color("#ff007f")
var _collect_dist := CRYSTAL_COLLECT_DIST

# VFX specs from docs/art_direction.md section 2.
const TRAIL_DURATION := 0.2 # "fading opacity (0.8 -> 0.0) over 200ms window"
const SNAP_FLASH_DURATION := 0.15 # "expands and fades out within 150ms"
const SNAP_FLASH_MAX_RADIUS := 45.0
const SHATTER_PARTICLE_COUNT := 24 # "break into 24 smaller glowing particle blocks"
const SHATTER_GRAVITY := 420.0 # "simple linear gravity pulling them down"

# {x: float, age: float}, oldest-to-newest not required — drawn in whatever order, age controls fade.
var _trail_left: Array = []
var _trail_right: Array = []

var _snap_flash_t := -1.0 # negative = inactive
var _snap_flash_center := Vector2.ZERO

# {pos: Vector2, vel: Vector2}
var _shatter_particles: Array = []
var _shatter_active := false

var active := false
var width := MIN_WIDTH
var target_width := MIN_WIDTH
var speed := 5.0
var score := 0.0
var combo := 1.0
var run_crystals := 0
var grazes_count := 0
var quick_snaps_count := 0
var _hold_started_at_ms := 0
var next_obstacle_time := 0.0
var _time_since_graze := 0.0

# {type: "center"|"side_left"|"side_right", y: float, resolved: bool}
var obstacles: Array = []
# {y: float, x: float}
var crystals: Array = []

var _hud: CanvasLayer
var _score_label: Label
var _crystals_label: Label
var _combo_label: Label

func _ready() -> void:
	_apply_skin_colors()
	if GameState.has_upgrade("double-crystals"):
		_collect_dist *= 1.2
	_build_hud()
	_start_run()

func _apply_skin_colors() -> void:
	var palette: Dictionary = COLORBLIND_COLORS.get(
		GameState.colorblind_mode,
		SKIN_COLORS.get(GameState.active_tether, SKIN_COLORS["default"])
	)
	_cyan = Color(palette.cyan)
	_magenta = Color(palette.magenta)

func _build_hud() -> void:
	_hud = CanvasLayer.new()
	add_child(_hud)

	_score_label = Label.new()
	_score_label.position = Vector2(16, 16)
	_score_label.add_theme_font_size_override("font_size", 22)
	_score_label.add_theme_color_override("font_color", _cyan)
	_hud.add_child(_score_label)

	_crystals_label = Label.new()
	_crystals_label.position = Vector2(16, 44)
	_crystals_label.add_theme_font_size_override("font_size", 16)
	_crystals_label.add_theme_color_override("font_color", COLOR_GREEN)
	_hud.add_child(_crystals_label)

	_combo_label = Label.new()
	_combo_label.position = Vector2(CANVAS_WIDTH - 100.0, 16)
	_combo_label.add_theme_font_size_override("font_size", 18)
	_combo_label.add_theme_color_override("font_color", _magenta)
	_combo_label.visible = false
	_hud.add_child(_combo_label)

func _start_run() -> void:
	score = 0.0
	run_crystals = 0
	combo = 1.0
	speed = BASE_SPEED
	_time_since_graze = 0.0
	width = MIN_WIDTH
	target_width = MIN_WIDTH
	obstacles.clear()
	crystals.clear()
	next_obstacle_time = 0.0
	_trail_left.clear()
	_trail_right.clear()
	_snap_flash_t = -1.0
	_shatter_particles.clear()
	_shatter_active = false
	active = true
	_score_label.text = "0m"
	_crystals_label.text = "0"
	_combo_label.visible = false
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_hold_start()
		else:
			_on_hold_end()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_hold_start()
		else:
			_on_hold_end()

func _on_hold_start() -> void:
	target_width = MAX_WIDTH
	_hold_started_at_ms = Time.get_ticks_msec()
	AudioSynth.play_split()
	_haptic(50)

func _on_hold_end() -> void:
	target_width = MIN_WIDTH
	if Time.get_ticks_msec() - _hold_started_at_ms < 200:
		quick_snaps_count += 1
	AudioSynth.play_merge()
	_haptic(80)
	# "The Snap Flash": circular white-glow shockwave on merge (art_direction.md 2).
	_snap_flash_t = 0.0
	_snap_flash_center = Vector2(CANVAS_WIDTH / 2.0, PLAYER_Y)

func _haptic(duration_ms: int) -> void:
	if GameState.haptics_enabled:
		Input.vibrate_handheld(duration_ms)

func _process(delta: float) -> void:
	# VFX (trail aging, snap flash, shatter burst) keep animating through the
	# ~0.6s crash-to-gameover delay even after `active` goes false, so the
	# shatter burst actually gets to play out instead of freezing mid-crash.
	if active:
		# Normalized to 60hz steps so feel/timing matches the prototype's
		# requestAnimationFrame-driven loop (which assumed a fixed 60fps),
		# but scales correctly on displays that aren't exactly 60Hz.
		var steps := delta * 60.0
		_advance(steps)
		_update_combo_decay(delta)
	_age_trail(delta)
	_update_snap_flash(delta)
	_update_shatter(delta)
	queue_redraw()

func _advance(steps: float) -> void:
	width += (target_width - width) * SPRING_LERP * steps

	var difficulty_t := clampf(score / DIFFICULTY_RAMP_SCORE, 0.0, 1.0)
	speed = lerpf(BASE_SPEED, MAX_SPEED, difficulty_t)

	next_obstacle_time -= steps
	if next_obstacle_time <= 0.0:
		_spawn()
		var spawn_min := lerpf(BASE_SPAWN_MIN, HARD_SPAWN_MIN, difficulty_t)
		var spawn_max := lerpf(BASE_SPAWN_MAX, HARD_SPAWN_MAX, difficulty_t)
		next_obstacle_time = spawn_min + randf() * (spawn_max - spawn_min)

	_move_and_collide(steps)
	_sample_trail()

	# Combo directly multiplies score gain now — grazing obstacles and
	# keeping the combo up is what actually pays off, not just a number
	# going up on screen for its own sake.
	score += steps * combo
	_score_label.text = "%dm" % int(score / 5.0)

func _update_combo_decay(delta: float) -> void:
	_time_since_graze += delta
	if _time_since_graze > COMBO_DECAY_DELAY and combo > 1.0:
		combo = maxf(1.0, combo - COMBO_DECAY_RATE * delta)
		_combo_label.text = "%.1fx" % combo

## "Tether Ribbon Trails": tapering ribbon with fading opacity 0.8 -> 0.0
## over a 200ms window (art_direction.md 2). Spheres only move horizontally
## here (Y is fixed at PLAYER_Y), so this is a per-sphere history of X only.
func _sample_trail() -> void:
	var sphere_offset := width / 2.0
	_trail_left.push_back({"x": CANVAS_WIDTH / 2.0 - sphere_offset, "age": 0.0})
	_trail_right.push_back({"x": CANVAS_WIDTH / 2.0 + sphere_offset, "age": 0.0})

func _age_trail(delta: float) -> void:
	for trail in [_trail_left, _trail_right]:
		for i in range(trail.size() - 1, -1, -1):
			trail[i].age += delta
			if trail[i].age > TRAIL_DURATION:
				trail.remove_at(i)

func _update_snap_flash(delta: float) -> void:
	if _snap_flash_t < 0.0:
		return
	_snap_flash_t += delta
	if _snap_flash_t > SNAP_FLASH_DURATION:
		_snap_flash_t = -1.0

## "Shatter Spark Burst": on hit, 24 particles scatter outward with gravity
## pulling them down (art_direction.md 2).
func _spawn_shatter(at: Vector2) -> void:
	_shatter_particles.clear()
	for i in SHATTER_PARTICLE_COUNT:
		var angle := (TAU / SHATTER_PARTICLE_COUNT) * i + randf_range(-0.2, 0.2)
		var spd := randf_range(80.0, 220.0)
		_shatter_particles.append({
			"pos": at,
			"vel": Vector2(cos(angle), sin(angle)) * spd,
		})
	_shatter_active = true

func _update_shatter(delta: float) -> void:
	if not _shatter_active:
		return
	for p in _shatter_particles:
		p.vel.y += SHATTER_GRAVITY * delta
		p.pos += p.vel * delta

func _spawn() -> void:
	if randf() < 0.6:
		if randf() < 0.5:
			obstacles.append({"type": "center", "y": -50.0, "resolved": false})
		else:
			var side := "side_left" if randf() < 0.5 else "side_right"
			obstacles.append({"type": side, "y": -50.0, "resolved": false})
	else:
		var lane_roll := randf()
		var x := CANVAS_WIDTH / 2.0
		if lane_roll < 0.33:
			x -= 60.0
		elif lane_roll > 0.66:
			x += 60.0
		crystals.append({"y": -50.0, "x": x})

func _move_and_collide(steps: float) -> void:
	var sphere_offset := width / 2.0
	var player_left_x := CANVAS_WIDTH / 2.0 - sphere_offset
	var player_right_x := CANVAS_WIDTH / 2.0 + sphere_offset

	for i in range(obstacles.size() - 1, -1, -1):
		var obs: Dictionary = obstacles[i]
		obs.y += speed * steps

		if not obs.resolved and abs(obs.y - PLAYER_Y) < GRAZE_BAND:
			var collision := false
			if obs.type == "center":
				collision = sphere_offset < CENTER_MERGE_THRESHOLD
			elif obs.type == "side_left":
				collision = player_left_x < SIDE_SAFE_MARGIN
			else:
				collision = player_right_x > (CANVAS_WIDTH - SIDE_SAFE_MARGIN)

			# Marking resolved here (even on a graze) fixes a prototype quirk:
			# app.js re-ran this check every frame the obstacle stayed inside
			# the band (several frames at this speed), so a single graze could
			# fire triggerGraze()/combo multiple times. See BUGS.md BUG-004.
			obs.resolved = true
			if collision:
				_crash()
				return
			else:
				_graze()

		if obs.y > CANVAS_HEIGHT + 50.0:
			obstacles.remove_at(i)

	for i in range(crystals.size() - 1, -1, -1):
		var cry: Dictionary = crystals[i]
		cry.y += speed * steps

		var dist_l := Vector2(cry.x - player_left_x, cry.y - PLAYER_Y).length()
		var dist_r := Vector2(cry.x - player_right_x, cry.y - PLAYER_Y).length()

		if dist_l < _collect_dist or dist_r < _collect_dist:
			crystals.remove_at(i)
			run_crystals += 1
			GameState.add_crystals(1)
			_crystals_label.text = str(run_crystals)
			_haptic(20)
			continue

		if cry.y > CANVAS_HEIGHT + 50.0:
			crystals.remove_at(i)

func _graze() -> void:
	combo += 0.1
	grazes_count += 1
	_time_since_graze = 0.0
	_combo_label.text = "%.1fx" % combo
	_combo_label.visible = true
	AudioSynth.play_graze()

func _crash() -> void:
	active = false
	AudioSynth.play_crash()
	_haptic(200)

	_spawn_shatter(Vector2(CANVAS_WIDTH / 2.0, PLAYER_Y))

	var distance := int(score / 5.0)
	GameState.record_run({
		"distance": distance,
		"crystals": run_crystals,
		"grazes": grazes_count,
		"quick_snaps": quick_snaps_count,
	})

	var collected := run_crystals
	var timer := get_tree().create_timer(0.6)
	timer.timeout.connect(func(): run_finished.emit(distance, collected))

func _draw() -> void:
	draw_rect(Rect2(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT), COLOR_BG, true)

	for obs in obstacles:
		var color: Color = _magenta if obs.type == "center" else _cyan
		var rect: Rect2
		if obs.type == "center":
			rect = Rect2(CANVAS_WIDTH / 2.0 - CENTER_OBSTACLE_WIDTH / 2.0, obs.y - OBSTACLE_HALF_HEIGHT, CENTER_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		elif obs.type == "side_left":
			rect = Rect2(10.0, obs.y - OBSTACLE_HALF_HEIGHT, SIDE_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		else:
			rect = Rect2(CANVAS_WIDTH - 110.0, obs.y - OBSTACLE_HALF_HEIGHT, SIDE_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		draw_rect(rect, Color(color, 0.15), true)
		draw_rect(rect, color, false, 2.0)

	for cry in crystals:
		var p: Vector2 = Vector2(cry.x, cry.y)
		var pts := PackedVector2Array([
			p + Vector2(0, -8), p + Vector2(8, 0), p + Vector2(0, 8), p + Vector2(-8, 0)
		])
		draw_colored_polygon(pts, COLOR_GREEN)

	_draw_trail(_trail_left, _cyan)
	_draw_trail(_trail_right, _magenta)

	if not _shatter_active:
		var sphere_offset := width / 2.0
		var left_pos := Vector2(CANVAS_WIDTH / 2.0 - sphere_offset, PLAYER_Y)
		var right_pos := Vector2(CANVAS_WIDTH / 2.0 + sphere_offset, PLAYER_Y)
		draw_line(left_pos, right_pos, _cyan, 2.0)
		draw_circle(left_pos, SPHERE_RADIUS, _cyan)
		draw_circle(right_pos, SPHERE_RADIUS, _magenta)

	if _snap_flash_t >= 0.0:
		var t := _snap_flash_t / SNAP_FLASH_DURATION
		var radius := lerpf(4.0, SNAP_FLASH_MAX_RADIUS, t)
		var alpha := lerpf(0.9, 0.0, t)
		draw_arc(_snap_flash_center, radius, 0.0, TAU, 32, Color(1, 1, 1, alpha), 3.0)

	if _shatter_active:
		for i in _shatter_particles.size():
			var p: Dictionary = _shatter_particles[i]
			var color: Color = _cyan if i % 2 == 0 else _magenta
			draw_rect(Rect2(p.pos - Vector2(3, 3), Vector2(6, 6)), color, true)

func _draw_trail(trail: Array, color: Color) -> void:
	for entry in trail:
		var t: float = entry.age / TRAIL_DURATION
		var alpha := lerpf(0.8, 0.0, t)
		var half_w := lerpf(4.0, 0.5, t)
		var x: float = entry.x
		draw_rect(Rect2(x - half_w, PLAYER_Y - half_w, half_w * 2.0, half_w * 2.0), Color(color, alpha), true)
