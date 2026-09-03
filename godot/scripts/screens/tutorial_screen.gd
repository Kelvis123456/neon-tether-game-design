extends Node2D

## Ported from prototype/index.html's #screen-tutorial + app.js's
## startTutorial/tutorialLoop/handleTutStart/handleTutEnd: a 3-step guided
## flow (hold to split, release to merge, done) that unlocks the
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
const MAX_WIDTH := 140.0
const SPHERE_RADIUS := 10.0
const COLOR_BG := Color(0.012, 0.012, 0.027)

var step := 1
var width := MIN_WIDTH
var target_width := MIN_WIDTH

var _hud: CanvasLayer
var _step_label: Label
var _instruction_label: Label
var _hint_label: Label
var _abandon_btn: Button
var _cyan := Color("#00f0ff")
var _magenta := Color("#ff007f")

func _ready() -> void:
	_build_hud()

func _build_hud() -> void:
	_hud = CanvasLayer.new()
	add_child(_hud)

	_step_label = UIHelpers.label("TUTORIAL STEP 1/3", 14, Color(1, 1, 1, 0.6), HORIZONTAL_ALIGNMENT_CENTER)
	_step_label.position = Vector2(25, 50)
	_step_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 24)
	_hud.add_child(_step_label)

	_instruction_label = UIHelpers.label("PRESS AND HOLD TO SPLIT CORE", 20, _cyan, HORIZONTAL_ALIGNMENT_CENTER, true)
	_instruction_label.position = Vector2(25, 80)
	_instruction_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 70)
	_hud.add_child(_instruction_label)

	_hint_label = UIHelpers.label("👆 HOLD ANYWHERE", 16, Color(1, 1, 1, 0.7), HORIZONTAL_ALIGNMENT_CENTER)
	_hint_label.position = Vector2(25, TETHER_Y + 50)
	_hint_label.custom_minimum_size = Vector2(CANVAS_WIDTH - 50, 30)
	_hud.add_child(_hint_label)

	_abandon_btn = UIHelpers.button("ABANDON SIMULATION", 260, 48)
	_abandon_btn.position = Vector2(CANVAS_WIDTH / 2.0 - 130, CANVAS_HEIGHT - 90)
	_abandon_btn.pressed.connect(func(): finished.emit())
	_hud.add_child(_abandon_btn)

func _input(event: InputEvent) -> void:
	if step >= 3:
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
	AudioSynth.play_split()
	if step == 1:
		step = 2
		_step_label.text = "TUTORIAL STEP 2/3"
		_instruction_label.text = "RELEASE NOW TO MERGE SNAP"

func _on_hold_end() -> void:
	target_width = MIN_WIDTH
	AudioSynth.play_merge()
	if step == 2:
		step = 3
		_step_label.text = "TUTORIAL STEP 3/3"
		_instruction_label.text = "TUTORIAL SYSTEM OPERATIONAL!\nFIRST TRANSMISSION UNLOCKED"
		_hint_label.visible = false
		_abandon_btn.disabled = true
		GameState.complete_tutorial()
		var timer := get_tree().create_timer(1.5)
		timer.timeout.connect(func(): finished.emit())

func _process(delta: float) -> void:
	var steps := delta * 60.0
	width += (target_width - width) * SPRING_LERP * steps
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT), COLOR_BG, true)

	var offset := width / 2.0
	var left_pos := Vector2(CANVAS_WIDTH / 2.0 - offset, TETHER_Y)
	var right_pos := Vector2(CANVAS_WIDTH / 2.0 + offset, TETHER_Y)
	draw_line(left_pos, right_pos, _cyan, 2.0)
	draw_circle(left_pos, SPHERE_RADIUS, _cyan)
	draw_circle(right_pos, SPHERE_RADIUS, _magenta)
