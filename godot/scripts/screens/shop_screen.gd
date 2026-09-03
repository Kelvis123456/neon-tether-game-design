extends Control

## Ported from prototype/index.html's #screen-shop: tethers/cores/upgrades
## tabs, crystal purchases go through GameState.buy_item(); real-money items
## show a "not available yet" notice instead of faking a charge (real IAP
## SDK integration is still a pending Phase 10 item — see TASK_LIST.md).

signal back_pressed

const UIHelpers = preload("res://scripts/ui_helpers.gd")
const SCREEN_WIDTH := 450.0

enum Tab { TETHERS, CORES, UPGRADES }
var _current_tab: Tab = Tab.TETHERS

var _list: VBoxContainer
var _crystal_label: Label
var _tab_buttons: Dictionary = {}
var _info_dialog: AcceptDialog

func _ready() -> void:
	add_child(UIHelpers.bg())
	add_child(UIHelpers.header("GRID SHOP", func(): back_pressed.emit()))

	_crystal_label = UIHelpers.label("", 16, UIHelpers.GREEN, HORIZONTAL_ALIGNMENT_RIGHT)
	_crystal_label.position = Vector2(SCREEN_WIDTH - 150.0, 20)
	_crystal_label.custom_minimum_size = Vector2(140, 30)
	add_child(_crystal_label)
	_update_crystal_label()
	GameState.crystals_changed.connect(func(_v): _update_crystal_label())

	var tabs := HBoxContainer.new()
	tabs.position = Vector2(10, 72)
	tabs.custom_minimum_size = Vector2(SCREEN_WIDTH - 20, 40)
	tabs.add_theme_constant_override("separation", 8)
	add_child(tabs)

	for entry in [["TETHERS", Tab.TETHERS], ["CORES", Tab.CORES], ["UPGRADES", Tab.UPGRADES]]:
		var b := UIHelpers.button(entry[0], (SCREEN_WIDTH - 36) / 3.0, 40)
		var tab_id: Tab = entry[1]
		b.pressed.connect(func(): _select_tab(tab_id))
		tabs.add_child(b)
		_tab_buttons[tab_id] = b

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(0, 122)
	scroll.custom_minimum_size = Vector2(SCREEN_WIDTH, 800.0 - 122.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(SCREEN_WIDTH - 20, 0)
	_list.position = Vector2(10, 0)
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

	_info_dialog = AcceptDialog.new()
	add_child(_info_dialog)

	_select_tab(Tab.TETHERS)

func _update_crystal_label() -> void:
	_crystal_label.text = "💎 %s" % _format_num(GameState.crystals)

func _format_num(n: int) -> String:
	return str(n)

func _select_tab(tab: Tab) -> void:
	_current_tab = tab
	for id in _tab_buttons:
		_tab_buttons[id].disabled = (id == tab)
	_render_list()

func _render_list() -> void:
	for child in _list.get_children():
		child.queue_free()

	match _current_tab:
		Tab.TETHERS:
			for entry in GameState.TETHER_CATALOG:
				_add_cosmetic_row(entry, "tether")
		Tab.CORES:
			for entry in GameState.CORE_CATALOG:
				_add_cosmetic_row(entry, "core")
		Tab.UPGRADES:
			for entry in GameState.UPGRADE_CATALOG:
				_add_upgrade_row(entry)

func _add_cosmetic_row(entry: Dictionary, kind: String) -> void:
	var row := PanelContainer.new()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)

	var name_label := UIHelpers.label(entry.name, 15, Color.WHITE)
	name_label.custom_minimum_size = Vector2(200, 40)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(name_label)

	var owned: bool = GameState.owned_items.has(entry.id)
	var active_id: String = GameState.active_tether if kind == "tether" else GameState.active_core

	if owned and active_id == entry.id:
		var status := UIHelpers.label("ACTIVE", 13, UIHelpers.GREEN, HORIZONTAL_ALIGNMENT_CENTER)
		status.custom_minimum_size = Vector2(140, 40)
		status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(status)
	elif owned:
		var select_btn := UIHelpers.button("SELECT", 140, 40)
		select_btn.pressed.connect(func():
			if kind == "tether":
				GameState.select_tether(entry.id)
			else:
				GameState.select_core(entry.id)
			_render_list()
		)
		hbox.add_child(select_btn)
	else:
		hbox.add_child(_buy_button(entry, kind))

	_list.add_child(row)

func _add_upgrade_row(entry: Dictionary) -> void:
	var row := PanelContainer.new()
	var vbox := VBoxContainer.new()
	row.add_child(vbox)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	vbox.add_child(top)

	var name_label := UIHelpers.label(entry.name, 15, Color.WHITE)
	name_label.custom_minimum_size = Vector2(200, 40)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(name_label)

	if GameState.has_upgrade(entry.id):
		var status := UIHelpers.label("OWNED", 13, UIHelpers.GREEN, HORIZONTAL_ALIGNMENT_CENTER)
		status.custom_minimum_size = Vector2(140, 40)
		status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		top.add_child(status)
	else:
		top.add_child(_buy_button(entry, "upgrade"))

	var desc := UIHelpers.label(entry.desc, 12, Color(1, 1, 1, 0.6), HORIZONTAL_ALIGNMENT_LEFT, true)
	desc.custom_minimum_size = Vector2(SCREEN_WIDTH - 40, 0)
	vbox.add_child(desc)

	_list.add_child(row)

func _buy_button(entry: Dictionary, kind: String) -> Button:
	var price_text := "💎 %s" % _format_num(entry.price) if entry.currency == "crystals" else "$%.2f" % entry.price
	var btn := UIHelpers.button(price_text, 140, 40)
	btn.pressed.connect(func(): _attempt_purchase(entry, kind))
	return btn

func _attempt_purchase(entry: Dictionary, kind: String) -> void:
	if entry.currency == "usd":
		_info_dialog.dialog_text = "%s ($%.2f) needs real store billing, which isn't wired up yet — coming with the real IAP/ad SDK integration (see TASK_LIST.md)." % [entry.name, entry.price]
		_info_dialog.popup_centered()
		return

	if GameState.crystals < entry.price:
		_info_dialog.dialog_text = "Not enough Volt Crystals for %s. Need 💎 %s, have 💎 %s." % [entry.name, _format_num(entry.price), _format_num(GameState.crystals)]
		_info_dialog.popup_centered()
		return

	GameState.buy_item(entry.id, entry.price)
	if kind == "tether":
		GameState.select_tether(entry.id)
	elif kind == "core":
		GameState.select_core(entry.id)
	_render_list()
