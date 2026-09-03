extends Control

## AppStateMachine (architecture.md): MENU / SHOP / ACHIEVEMENTS / SETTINGS /
## EVENTS / PLAYING / GAMEOVER. Screens are built by scripts/screens/*.gd
## (plain Control scripts, no hand-authored .tscn per screen — see those
## files for why) and routed here.

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const GAMEPLAY_SCENE := preload("res://scenes/Gameplay.tscn")
const SHOP_SCREEN := preload("res://scripts/screens/shop_screen.gd")
const ACHIEVEMENTS_SCREEN := preload("res://scripts/screens/achievements_screen.gd")
const SETTINGS_SCREEN := preload("res://scripts/screens/settings_screen.gd")
const EVENTS_SCREEN := preload("res://scripts/screens/events_screen.gd")

var _gameplay = null # untyped: gameplay.gd's custom `run_finished` signal isn't on Node's static API
var _menu_layer: CanvasLayer
var _gameover_layer: CanvasLayer
var _sub_screen_layer: CanvasLayer # shop / achievements / settings / events

func _ready() -> void:
	_show_menu()

func _show_menu() -> void:
	_clear_gameplay()
	_clear_gameover()
	_clear_sub_screen()

	_menu_layer = CanvasLayer.new()
	add_child(_menu_layer)

	_menu_layer.add_child(UIHelpers.bg(Color(0.043, 0.043, 0.086, 1.0)))

	var title := UIHelpers.label("NEON TETHER", 40, UIHelpers.CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-200, 220)
	title.custom_minimum_size = Vector2(400, 60)
	_menu_layer.add_child(title)

	var crystal_label := UIHelpers.label("💎 %d" % GameState.crystals, 16, UIHelpers.GREEN, HORIZONTAL_ALIGNMENT_CENTER)
	crystal_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	crystal_label.position = Vector2(-200, 280)
	crystal_label.custom_minimum_size = Vector2(400, 26)
	_menu_layer.add_child(crystal_label)

	var best_label := UIHelpers.label("BEST: %dm" % GameState.best_score, 18, Color(1, 1, 1, 0.7), HORIZONTAL_ALIGNMENT_CENTER)
	best_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	best_label.position = Vector2(-200, 310)
	best_label.custom_minimum_size = Vector2(400, 30)
	_menu_layer.add_child(best_label)

	var play_btn := UIHelpers.button("PLAY", 200, 64)
	play_btn.set_anchors_preset(Control.PRESET_CENTER)
	play_btn.position = Vector2(-100, -70)
	play_btn.pressed.connect(_start_game)
	_menu_layer.add_child(play_btn)

	var nav := HBoxContainer.new()
	nav.set_anchors_preset(Control.PRESET_CENTER)
	nav.position = Vector2(-200, 20)
	nav.custom_minimum_size = Vector2(400, 48)
	nav.add_theme_constant_override("separation", 8)
	_menu_layer.add_child(nav)

	var nav_entries := [
		["SHOP", func(): _show_sub_screen(SHOP_SCREEN)],
		["LOGS", func(): _show_sub_screen(ACHIEVEMENTS_SCREEN)],
		["EVENTS", func(): _show_sub_screen(EVENTS_SCREEN)],
		["CONFIG", func(): _show_sub_screen(SETTINGS_SCREEN)],
	]
	for entry in nav_entries:
		var b := UIHelpers.button(entry[0], 92, 44)
		b.pressed.connect(entry[1])
		nav.add_child(b)

	AudioSynth.enabled = GameState.music_enabled
	AudioSynth.start_bgm()

func _show_sub_screen(screen_script: GDScript) -> void:
	_clear_sub_screen()
	_sub_screen_layer = CanvasLayer.new()
	add_child(_sub_screen_layer)

	var screen = screen_script.new() # untyped: back_pressed isn't on Control's static API
	# A fresh Control defaults to a 0x0 rect. Its own anchors resolve against
	# the viewport (it's a direct child of a CanvasLayer, not another
	# Control), but its CHILDREN's anchors resolve against *this* rect — so
	# without this, every full-rect/full-width child inside the screen
	# (background, header) collapses to 0x0 too, and the menu underneath
	# shows straight through. Found via the in-engine screenshot test.
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.back_pressed.connect(_clear_sub_screen)
	_sub_screen_layer.add_child(screen)

func _clear_sub_screen() -> void:
	if _sub_screen_layer:
		_sub_screen_layer.queue_free()
		_sub_screen_layer = null

func _start_game() -> void:
	_clear_menu()
	AudioSynth.stop_bgm()
	_gameplay = GAMEPLAY_SCENE.instantiate()
	_gameplay.run_finished.connect(_on_run_finished)
	add_child(_gameplay)

func _on_run_finished(distance: int, crystals_collected: int) -> void:
	_clear_gameplay()
	_show_gameover(distance, crystals_collected)

func _show_gameover(distance: int, crystals_collected: int) -> void:
	_gameover_layer = CanvasLayer.new()
	add_child(_gameover_layer)

	_gameover_layer.add_child(UIHelpers.bg(Color(0.043, 0.043, 0.086, 1.0)))

	var result := UIHelpers.label(
		"CRASHED\n%dm  (+%d crystals)\nBEST: %dm" % [distance, crystals_collected, GameState.best_score],
		24, UIHelpers.MAGENTA, HORIZONTAL_ALIGNMENT_CENTER
	)
	result.set_anchors_preset(Control.PRESET_CENTER_TOP)
	result.position = Vector2(-200, 260)
	result.custom_minimum_size = Vector2(400, 140)
	_gameover_layer.add_child(result)

	# Positioned to clear the result label's reserved box (260 to 400) below,
	# not just its text — a first live playtest showed RETRY rendering on top
	# of the result text because these two boxes overlapped by design.
	var retry_btn := UIHelpers.button("RETRY", 200, 56)
	retry_btn.set_anchors_preset(Control.PRESET_CENTER)
	retry_btn.position = Vector2(-100, 20)
	retry_btn.pressed.connect(func():
		_clear_gameover()
		_start_game()
	)
	_gameover_layer.add_child(retry_btn)

	var menu_btn := UIHelpers.button("MENU", 200, 56)
	menu_btn.set_anchors_preset(Control.PRESET_CENTER)
	menu_btn.position = Vector2(-100, 90)
	menu_btn.pressed.connect(func():
		_clear_gameover()
		_show_menu()
	)
	_gameover_layer.add_child(menu_btn)

func _clear_menu() -> void:
	if _menu_layer:
		_menu_layer.queue_free()
		_menu_layer = null

func _clear_gameplay() -> void:
	if _gameplay:
		_gameplay.queue_free()
		_gameplay = null

func _clear_gameover() -> void:
	if _gameover_layer:
		_gameover_layer.queue_free()
		_gameover_layer = null
