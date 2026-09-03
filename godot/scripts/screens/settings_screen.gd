extends Control

## Ported from prototype/index.html's #screen-settings: music/haptics
## toggles + colorblind mode selector, all writing straight to GameState.

signal back_pressed

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const SCREEN_WIDTH := 450.0

func _ready() -> void:
	add_child(UIHelpers.bg())
	add_child(UIHelpers.header("CONFIGURATION", func(): back_pressed.emit()))

	var list := VBoxContainer.new()
	list.position = Vector2(20, 90)
	list.custom_minimum_size = Vector2(SCREEN_WIDTH - 40, 0)
	list.add_theme_constant_override("separation", 20)
	add_child(list)

	list.add_child(_toggle_row("CYBER AUDIOS (MUSIC)", GameState.music_enabled, func(on):
		GameState.music_enabled = on
		AudioSynth.enabled = on
		if not on:
			AudioSynth.stop_bgm()
		GameState.save()
	))

	list.add_child(_toggle_row("TACTILE DRIVES (HAPTICS)", GameState.haptics_enabled, func(on):
		GameState.haptics_enabled = on
		GameState.save()
	))

	list.add_child(_colorblind_row())

	var about := UIHelpers.label(
		"NEON TETHER — GODOT PRODUCTION BUILD (PHASE 10, IN PROGRESS)\nORIGINAL GAME DESIGN — NO FRANCHISE AFFILIATION",
		11, Color(1, 1, 1, 0.4), HORIZONTAL_ALIGNMENT_CENTER, true
	)
	about.position = Vector2(20, 700)
	about.custom_minimum_size = Vector2(SCREEN_WIDTH - 40, 60)
	add_child(about)

func _toggle_row(text: String, initial: bool, on_toggled: Callable) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var label := UIHelpers.label(text, 13, Color.WHITE)
	label.custom_minimum_size = Vector2(260, 32)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var check := CheckButton.new()
	check.button_pressed = initial
	check.toggled.connect(on_toggled)
	row.add_child(check)

	return row

func _colorblind_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var label := UIHelpers.label("COLOR BLIND MODE", 13, Color.WHITE)
	label.custom_minimum_size = Vector2(180, 32)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	var options := OptionButton.new()
	options.custom_minimum_size = Vector2(200, 36)
	var modes := [["none", "STANDARD NEON"], ["protan", "PROTANOPIA (R/B)"], ["deuteran", "DEUTERANOPIA (G/B)"]]
	var selected_index := 0
	for i in modes.size():
		options.add_item(modes[i][1], i)
		if modes[i][0] == GameState.colorblind_mode:
			selected_index = i
	options.select(selected_index)
	options.item_selected.connect(func(index: int):
		GameState.colorblind_mode = modes[index][0]
		GameState.save()
	)
	row.add_child(options)

	return row
