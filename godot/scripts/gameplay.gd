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
	speed = 5.0
	width = MIN_WIDTH
	target_width = MIN_WIDTH
	obstacles.clear()
	crystals.clear()
	next_obstacle_time = 0.0
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

func _haptic(duration_ms: int) -> void:
	if GameState.haptics_enabled:
		Input.vibrate_handheld(duration_ms)

func _process(delta: float) -> void:
	if not active:
		return
	# Normalized to 60hz steps so feel/timing matches the prototype's
	# requestAnimationFrame-driven loop (which assumed a fixed 60fps),
	# but scales correctly on displays that aren't exactly 60Hz.
	var steps := delta * 60.0
	_advance(steps)
	queue_redraw()

func _advance(steps: float) -> void:
	width += (target_width - width) * SPRING_LERP * steps

	next_obstacle_time -= steps
	if next_obstacle_time <= 0.0:
		_spawn()
		next_obstacle_time = 50.0 + randf() * 40.0

	_move_and_collide(steps)

	score += steps
	_score_label.text = "%dm" % int(score / 5.0)

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
	_combo_label.text = "%.1fx" % combo
	_combo_label.visible = true
	AudioSynth.play_graze()

func _crash() -> void:
	active = false
	AudioSynth.play_crash()
	_haptic(200)

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

	var sphere_offset := width / 2.0
	var left_pos := Vector2(CANVAS_WIDTH / 2.0 - sphere_offset, PLAYER_Y)
	var right_pos := Vector2(CANVAS_WIDTH / 2.0 + sphere_offset, PLAYER_Y)
	draw_line(left_pos, right_pos, _cyan, 2.0)
	draw_circle(left_pos, SPHERE_RADIUS, _cyan)
	draw_circle(right_pos, SPHERE_RADIUS, _magenta)
