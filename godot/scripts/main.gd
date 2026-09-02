extends Control

## Minimal AppStateMachine (architecture.md): MENU / PLAYING / GAMEOVER.
## This is a functional placeholder shell to host the real gameplay loop —
## not the full menu/shop/settings UI, which is separate remaining Phase 10
## scope (see TASK_LIST.md).

const GAMEPLAY_SCENE := preload("res://scenes/Gameplay.tscn")

var _gameplay = null # untyped: gameplay.gd's custom `run_finished` signal isn't on Node's static API
var _menu_layer: CanvasLayer
var _gameover_layer: CanvasLayer

func _ready() -> void:
	_show_menu()

func _show_menu() -> void:
	_clear_gameplay()
	_clear_gameover()

	_menu_layer = CanvasLayer.new()
	add_child(_menu_layer)

	var bg := ColorRect.new()
	bg.color = Color(0.043, 0.043, 0.086, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_layer.add_child(bg)

	var title := Label.new()
	title.text = "NEON TETHER"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("#00f0ff"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(-200, 260)
	title.custom_minimum_size = Vector2(400, 60)
	_menu_layer.add_child(title)

	var best_label := Label.new()
	best_label.text = "BEST: %dm" % GameState.best_score
	best_label.add_theme_font_size_override("font_size", 18)
	best_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	best_label.position = Vector2(-200, 320)
	best_label.custom_minimum_size = Vector2(400, 30)
	_menu_layer.add_child(best_label)

	var play_btn := Button.new()
	play_btn.text = "PLAY"
	play_btn.custom_minimum_size = Vector2(200, 64)
	play_btn.set_anchors_preset(Control.PRESET_CENTER)
	play_btn.position = Vector2(-100, -32)
	play_btn.pressed.connect(_start_game)
	_menu_layer.add_child(play_btn)

	AudioSynth.enabled = GameState.music_enabled
	AudioSynth.start_bgm()

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

	var bg := ColorRect.new()
	bg.color = Color(0.043, 0.043, 0.086, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_gameover_layer.add_child(bg)

	var result := Label.new()
	result.text = "CRASHED\n%dm  (+%d crystals)\nBEST: %dm" % [distance, crystals_collected, GameState.best_score]
	result.add_theme_font_size_override("font_size", 24)
	result.add_theme_color_override("font_color", Color("#ff007f"))
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.set_anchors_preset(Control.PRESET_CENTER_TOP)
	result.position = Vector2(-200, 280)
	result.custom_minimum_size = Vector2(400, 120)
	_gameover_layer.add_child(result)

	var retry_btn := Button.new()
	retry_btn.text = "RETRY"
	retry_btn.custom_minimum_size = Vector2(200, 56)
	retry_btn.set_anchors_preset(Control.PRESET_CENTER)
	retry_btn.position = Vector2(-100, -80)
	retry_btn.pressed.connect(func():
		_clear_gameover()
		_start_game()
	)
	_gameover_layer.add_child(retry_btn)

	var menu_btn := Button.new()
	menu_btn.text = "MENU"
	menu_btn.custom_minimum_size = Vector2(200, 56)
	menu_btn.set_anchors_preset(Control.PRESET_CENTER)
	menu_btn.position = Vector2(-100, -10)
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
