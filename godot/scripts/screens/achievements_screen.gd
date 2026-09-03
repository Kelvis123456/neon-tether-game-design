extends Control

## Ported from prototype/index.html's #screen-achievements, driven by real
## progress in GameState (achievement_progress / unlocked_achievements)
## instead of the prototype's hardcoded percentages.

signal back_pressed

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const SCREEN_WIDTH := 450.0
const TARGETS := {
	"crystal_energy": 100,
	"strike_the_tether": 50,
}

func _ready() -> void:
	add_child(UIHelpers.bg())
	add_child(UIHelpers.header("SYSTEM ACHIEVEMENTS", func(): back_pressed.emit()))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 74)
	scroll.custom_minimum_size = Vector2(SCREEN_WIDTH, 800.0 - 74.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var list := VBoxContainer.new()
	list.custom_minimum_size = Vector2(SCREEN_WIDTH - 20, 0)
	list.position = Vector2(10, 0)
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)

	for entry in GameState.ACHIEVEMENTS:
		list.add_child(_build_card(entry))

func _build_card(entry: Dictionary) -> Control:
	var unlocked: bool = GameState.unlocked_achievements.has(entry.id)
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	vbox.add_child(top)

	var name_color: Color = UIHelpers.GREEN if unlocked else Color.WHITE
	var name_label := UIHelpers.label(entry.name, 15, name_color)
	name_label.custom_minimum_size = Vector2(240, 30)
	top.add_child(name_label)

	var reward_text := "UNLOCKED" if unlocked else ("🔒" if entry.reward == 0 else "💎 %d" % entry.reward)
	top.add_child(UIHelpers.label(reward_text, 13, UIHelpers.ORANGE, HORIZONTAL_ALIGNMENT_RIGHT))

	var desc := UIHelpers.label(entry.desc, 12, Color(1, 1, 1, 0.6), HORIZONTAL_ALIGNMENT_LEFT, true)
	desc.custom_minimum_size = Vector2(SCREEN_WIDTH - 40, 0)
	vbox.add_child(desc)

	if not unlocked and TARGETS.has(entry.id):
		var target: int = TARGETS[entry.id]
		var progress: int = GameState.achievement_progress.get(entry.id, 0)
		vbox.add_child(UIHelpers.label("%d / %d" % [min(progress, target), target], 12, Color(1, 1, 1, 0.5)))
	elif not unlocked and entry.id == "cyber_master":
		var total := GameState.TETHER_CATALOG.size() + GameState.CORE_CATALOG.size()
		var owned := 0
		for cat in [GameState.TETHER_CATALOG, GameState.CORE_CATALOG]:
			for item in cat:
				if GameState.owned_items.has(item.id):
					owned += 1
		vbox.add_child(UIHelpers.label("%d / %d items owned" % [owned, total], 12, Color(1, 1, 1, 0.5)))

	return panel
