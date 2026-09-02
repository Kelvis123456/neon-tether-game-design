extends Node

## Persistent player profile: crystals, best score, cosmetics, settings.
## Mirrors the browser prototype's `state` object (see prototype/app.js)
## minus per-run gameplay fields, which live in Gameplay itself.

signal crystals_changed(new_total: int)

const DEFAULT_TETHER := "default"
const DEFAULT_CORE := "core-default"

var crystals: int = 0
var best_score: int = 0
var active_tether: String = DEFAULT_TETHER
var active_core: String = DEFAULT_CORE
var owned_items: Array = [DEFAULT_TETHER, DEFAULT_CORE]
var run_history: Array = []
var colorblind_mode: String = "none"
var music_enabled: bool = true
var haptics_enabled: bool = true

func _ready() -> void:
	var data := SaveSystem.load_data()
	if data.is_empty():
		return
	crystals = data.get("crystals", crystals)
	best_score = data.get("best_score", best_score)
	active_tether = data.get("active_tether", active_tether)
	active_core = data.get("active_core", active_core)
	owned_items = data.get("owned_items", owned_items)
	run_history = data.get("run_history", run_history)
	colorblind_mode = data.get("colorblind_mode", colorblind_mode)
	music_enabled = data.get("music_enabled", music_enabled)
	haptics_enabled = data.get("haptics_enabled", haptics_enabled)

func add_crystals(amount: int) -> void:
	crystals += amount
	crystals_changed.emit(crystals)

func record_run(distance: int) -> void:
	if distance > best_score:
		best_score = distance
	run_history.append(distance)
	if run_history.size() > 20:
		run_history.pop_front()
	save()

func save() -> void:
	SaveSystem.save_data({
		"crystals": crystals,
		"best_score": best_score,
		"active_tether": active_tether,
		"active_core": active_core,
		"owned_items": owned_items,
		"run_history": run_history,
		"colorblind_mode": colorblind_mode,
		"music_enabled": music_enabled,
		"haptics_enabled": haptics_enabled,
	})
