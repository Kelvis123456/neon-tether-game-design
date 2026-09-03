extends Node2D

## Ported from prototype/index.html's #screen-tutorial + app.js's
## startTutorial/tutorialLoop/handleTutStart/handleTutEnd, then expanded with
## two briefing steps: the original 3-step flow only ever taught the RAW
## INPUT (hold=split, release=merge) without ever showing an obstacle, so a
## player could finish it and still not know which color they had to dodge
## with which action. Steps 1-2 now show the actual center/side obstacle
## shapes from gameplay.gd: first the WRONG tether state actually touching
## the obstacle (a real collision pose, not just a distant illustration —
## see gameplay.gd's MAX_WIDTH comment for why the old 140 value never let
## the tether reach that far), then the correct state that clears it, before
## steps 3-5 (unchanged practice flow) drill the input itself. Unlocks the
## "first_transmission" achievement — previously unreachable in the Godot
## port, since nothing else ever completed it.
##
## A Node2D (not Control) like gameplay.gd, for the same reason: the tether
## visualization is drawn via _draw(), and that has to include its own
## background fill. An opaque background placed in the CanvasLayer instead
## would render *above* _draw()'s layer-0 content and hide the spheres
## entirely (CanvasLayer defaults to layer 1) — this is deliberately built
## the same way gameplay.gd already does it correctly.

signal finished

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const CANVAS_WIDTH := 450.0
const CANVAS_HEIGHT := 800.0
const TETHER_Y := 420.0
const SPRING_LERP := 0.18
const MIN_WIDTH := 10.0
const MAX_WIDTH := 290.0 # kept in sync with gameplay.gd's MAX_WIDTH
const SPHERE_RADIUS := 10.0
const COLOR_BG := Color(0.012, 0.012, 0.027)

# Mirrors gameplay.gd's CENTER_OBSTACLE_WIDTH / SIDE_OBSTACLE_WIDTH and its
# obstacle rects, so the briefing illustration matches what actually spawns
# in a real run instead of being a made-up approximation.
const CENTER_OBSTACLE_WIDTH := 60.0
const SIDE_OBSTACLE_WIDTH := 100.0
const OBSTACLE_HALF_HEIGHT := 40.0

const DANGER_PREVIEW_DURATION := 1.1

const STEP_BRIEF_MAGENTA := 1
const STEP_BRIEF_CYAN := 2
const STEP_PRACTICE_HOLD := 3
const STEP_PRACTICE_RELEASE := 4
const STEP_DONE := 5

var step := STEP_BRIEF_MAGENTA
var width := MIN_WIDTH
var target_width := MIN_WIDTH

var _brief_t := 0.0
var _brief_revealed := false

var _hud: CanvasLayer
var _step_label: Label
var _instruction_label: Label
var _hint_label: Label
var _abandon_btn: Button
var _cyan := Color("#00f0ff")
var _magenta := Color("#ff007f")
var _danger := Color("#ff3b3b")

func _ready() -> void:
	_build_hud()
	# Step 1 starts in its DANGER pose already: default width is MIN_WIDTH
	# (merged), which is exactly what collides with the center obstacle.

func _build_hud() -> void:
	_hud = CanvasLayer.new()
	add_child(_hud)

	_step_label = UIHelpers.label("TUTORIAL STEP 1/5", 14, Color(1, 1, 1, 0.6), HORIZONTAL_ALIGNMENT_CENTER)
	_step_label.position = Vector2(25, 50)
	_step_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 24)
	_hud.add_child(_step_label)

	_instruction_label = UIHelpers.label("MAGENTA BLOCKS THE CENTER", 20, _magenta, HORIZONTAL_ALIGNMENT_CENTER, true)
	_instruction_label.position = Vector2(25, 80)
	_instruction_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 70)
	_hud.add_child(_instruction_label)

	_hint_label = UIHelpers.label("⚠ STAY MERGED AND THIS HAPPENS", 15, _danger, HORIZONTAL_ALIGNMENT_CENTER, true)
	_hint_label.position = Vector2(25, TETHER_Y + 55)
	_hint_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 44)
	_hud.add_child(_hint_label)

	_abandon_btn = UIHelpers.button("ABANDON SIMULATION", 260, 48)
	_abandon_btn.position = Vector2(CANVAS_WIDTH / 2.0 - 130, CANVAS_HEIGHT - 90)
	_abandon_btn.pressed.connect(func(): finished.emit())
	_hud.add_child(_abandon_btn)

func _input(event: InputEvent) -> void:
	if step >= STEP_DONE:
		return

	var pressed := false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.pressed
	else:
		return

	if step == STEP_BRIEF_MAGENTA or step == STEP_BRIEF_CYAN:
		# Ignored until the danger→safe reveal has played, so the player
		# always sees the crash pose before they can skip past it.
		if pressed and _brief_revealed:
			_advance_briefing()
	elif pressed:
		_on_hold_start()
	else:
		_on_hold_end()

func _advance_briefing() -> void:
	if step == STEP_BRIEF_MAGENTA:
		step = STEP_BRIEF_CYAN
		_step_label.text = "TUTORIAL STEP 2/5"
		_instruction_label.text = "CYAN BLOCKS THE SIDES"
		_instruction_label.add_theme_color_override("font_color", _cyan)
		_start_briefing_danger(MAX_WIDTH)
	elif step == STEP_BRIEF_CYAN:
		step = STEP_PRACTICE_HOLD
		_step_label.text = "TUTORIAL STEP 3/5"
		_instruction_label.text = "PRESS AND HOLD TO SPLIT CORE"
		_instruction_label.add_theme_color_override("font_color", _cyan)
		_hint_label.text = "👆 HOLD ANYWHERE"
		_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		width = MIN_WIDTH
		target_width = MIN_WIDTH

func _start_briefing_danger(danger_width: float) -> void:
	_brief_t = 0.0
	_brief_revealed = false
	width = danger_width
	target_width = danger_width
	_hint_label.add_theme_color_override("font_color", _danger)
	_hint_label.text = "⚠ STAY MERGED AND THIS HAPPENS" if step == STEP_BRIEF_MAGENTA else "⚠ STAY SPLIT WIDE AND THIS HAPPENS"

func _reveal_briefing_safe() -> void:
	_brief_revealed = true
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	if step == STEP_BRIEF_MAGENTA:
		target_width = MAX_WIDTH
		_hint_label.text = "SPLIT WIDE TO CLEAR IT — 👆 TAP TO CONTINUE"
	else:
		target_width = MIN_WIDTH
		_hint_label.text = "MERGE NARROW TO SLIP THROUGH — 👆 TAP TO CONTINUE"

func _on_hold_start() -> void:
	target_width = MAX_WIDTH
	AudioSynth.play_split()
	if step == STEP_PRACTICE_HOLD:
		step = STEP_PRACTICE_RELEASE
		_step_label.text = "TUTORIAL STEP 4/5"
		_instruction_label.text = "RELEASE NOW TO MERGE SNAP"

func _on_hold_end() -> void:
	target_width = MIN_WIDTH
	AudioSynth.play_merge()
	if step == STEP_PRACTICE_RELEASE:
		step = STEP_DONE
		_step_label.text = "TUTORIAL STEP 5/5"
		_instruction_label.text = "TUTORIAL SYSTEM OPERATIONAL!\nFIRST TRANSMISSION UNLOCKED"
		_hint_label.visible = false
		_abandon_btn.disabled = true
		GameState.complete_tutorial()
		var timer := get_tree().create_timer(1.5)
		timer.timeout.connect(func(): finished.emit())

func _process(delta: float) -> void:
	var steps := delta * 60.0
	width += (target_width - width) * SPRING_LERP * steps

	if (step == STEP_BRIEF_MAGENTA or step == STEP_BRIEF_CYAN) and not _brief_revealed:
		_brief_t += delta
		if _brief_t >= DANGER_PREVIEW_DURATION:
			_reveal_briefing_safe()

	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT), COLOR_BG, true)

	var danger_active := (step == STEP_BRIEF_MAGENTA or step == STEP_BRIEF_CYAN) and not _brief_revealed
	var fill_alpha := 0.35 if danger_active else 0.15

	if step == STEP_BRIEF_MAGENTA:
		var rect := Rect2(CANVAS_WIDTH / 2.0 - CENTER_OBSTACLE_WIDTH / 2.0, TETHER_Y - OBSTACLE_HALF_HEIGHT, CENTER_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		draw_rect(rect, Color(_magenta, fill_alpha), true)
		draw_rect(rect, _danger if danger_active else _magenta, false, 2.0)
	elif step == STEP_BRIEF_CYAN:
		var left_rect := Rect2(10.0, TETHER_Y - OBSTACLE_HALF_HEIGHT, SIDE_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		var right_rect := Rect2(CANVAS_WIDTH - 110.0, TETHER_Y - OBSTACLE_HALF_HEIGHT, SIDE_OBSTACLE_WIDTH, OBSTACLE_HALF_HEIGHT * 2.0)
		draw_rect(left_rect, Color(_cyan, fill_alpha), true)
		draw_rect(left_rect, _danger if danger_active else _cyan, false, 2.0)
		draw_rect(right_rect, Color(_cyan, fill_alpha), true)
		draw_rect(right_rect, _danger if danger_active else _cyan, false, 2.0)

	var offset := width / 2.0
	var left_pos := Vector2(CANVAS_WIDTH / 2.0 - offset, TETHER_Y)
	var right_pos := Vector2(CANVAS_WIDTH / 2.0 + offset, TETHER_Y)
	draw_line(left_pos, right_pos, _cyan, 2.0)
	draw_circle(left_pos, SPHERE_RADIUS, _danger if danger_active else _cyan)
	draw_circle(right_pos, SPHERE_RADIUS, _danger if danger_active else _magenta)
