extends Control

## Ported from prototype/index.html's #screen-events: the daily challenge
## banner + leaderboard (flavor NPC scores + the real player row, same as
## app.js's renderLeaderboard()). Adds the daily missions list described in
## docs/GDD.md 2.2 ("Complete 3 dynamic objectives daily"), which the
## browser prototype never actually built.

signal back_pressed

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const SCREEN_WIDTH := 450.0
const NPC_SCORES := [
	{"name": "MATRIX_CRASHER", "score": 4890},
	{"name": "CYBER_PULSE", "score": 4120},
	{"name": "TETHER_GOD", "score": 3980},
]

func _ready() -> void:
	add_child(UIHelpers.bg())
	add_child(UIHelpers.header("LIVE MATRIX EVENTS", func(): back_pressed.emit()))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 74)
	scroll.custom_minimum_size = Vector2(SCREEN_WIDTH, 800.0 - 74.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var list := VBoxContainer.new()
	list.custom_minimum_size = Vector2(SCREEN_WIDTH - 20, 0)
	list.position = Vector2(10, 0)
	list.add_theme_constant_override("separation", 16)
	scroll.add_child(list)

	list.add_child(UIHelpers.label("DAILY MISSIONS", 16, UIHelpers.CYAN))
	for m in GameState.missions:
		list.add_child(_mission_row(m))

	list.add_child(UIHelpers.label("GLOBAL LEADERBOARD (TODAY)", 16, UIHelpers.CYAN))
	for row in _leaderboard_rows():
		list.add_child(_leaderboard_row(row))

func _mission_row(m: Dictionary) -> Control:
	var vbox := VBoxContainer.new()
	var color: Color = UIHelpers.GREEN if m.completed else Color.WHITE
	var mark := "✓ " if m.completed else ""
	var mission_label := UIHelpers.label(mark + m.label, 13, color, HORIZONTAL_ALIGNMENT_LEFT, true)
	mission_label.custom_minimum_size = Vector2(SCREEN_WIDTH - 20, 0)
	vbox.add_child(mission_label)
	var bar := ProgressBar.new()
	bar.max_value = m.target
	bar.value = min(m.progress, m.target)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(bar)
	vbox.add_child(UIHelpers.label("%d / %d  (reward: 💎 %d)" % [m.progress, m.target, GameState.MISSION_REWARD], 11, Color(1, 1, 1, 0.5)))
	return vbox

func _leaderboard_rows() -> Array:
	var rows: Array = NPC_SCORES.duplicate(true)
	rows.append({"name": "PILOT_01 (YOU)", "score": GameState.best_score, "is_player": true})
	rows.sort_custom(func(a, b): return a.score > b.score)
	return rows

func _leaderboard_row(entry: Dictionary) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	var color: Color = UIHelpers.MAGENTA if entry.get("is_player", false) else Color.WHITE

	var name_label := UIHelpers.label(entry.name, 13, color)
	name_label.custom_minimum_size = Vector2(220, 26)
	hbox.add_child(name_label)
	hbox.add_child(UIHelpers.label("%dm" % entry.score, 13, color, HORIZONTAL_ALIGNMENT_RIGHT))
	return hbox
