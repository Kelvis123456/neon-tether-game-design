extends Node

## Persistent player profile + shop catalog + achievements + daily missions.
## Catalog/achievement content ported from prototype/index.html; mission
## templates ported from docs/GDD.md section 2.2 ("Complete 3 dynamic
## objectives daily").

signal crystals_changed(new_total: int)

const DEFAULT_TETHER := "default"
const DEFAULT_CORE := "core-default"

# currency: "crystals" (price is an int deducted from GameState.crystals) or
# "usd" (price is a real-money amount; purchase requires a store SDK we don't
# have yet, so the shop UI shows a "not available yet" notice instead of
# faking a successful charge).
const TETHER_CATALOG := [
	{"id": "default", "name": "NEON PLASMA", "price": 0, "currency": "crystals"},
	{"id": "laser", "name": "RUBY LASER", "price": 500, "currency": "crystals"},
	{"id": "plasma", "name": "CORONA WAVE", "price": 800, "currency": "crystals"},
	{"id": "rainbow", "name": "RAINBOW ARC", "price": 0.99, "currency": "usd"},
]

const CORE_CATALOG := [
	{"id": "core-default", "name": "STANDARD NODE", "price": 0, "currency": "crystals"},
	{"id": "core-shield", "name": "AEGIS CORE", "price": 400, "currency": "crystals"},
	{"id": "core-galaxy", "name": "NEBULA CORE", "price": 0.99, "currency": "usd"},
]

const UPGRADE_CATALOG := [
	{"id": "double-crystals", "name": "CRYSTAL VACUUM", "desc": "Increases collect radius by 20%", "price": 1000, "currency": "crystals"},
	{"id": "ad-removal", "name": "SYSTEM BYPASS", "desc": "Removes ads & grants 1 free continue per run", "price": 2.99, "currency": "usd"},
]

# "first_transmission" unlocks via GameState.complete_tutorial(), called from
# scripts/screens/tutorial_screen.gd on completing the guided flow.
# "cyber_master" needs every catalog item owned, premium ones included, so it
# stays locked until real IAP ships.
# "strike_the_tether"'s "without split lock" is prototype flavor text
# (prototype/index.html) never mechanically defined in any doc — with this
# game's actual collision rules (merged = vulnerable to center pillars,
# split = vulnerable to side pillars), "never splitting" would mean dying on
# the first center pillar, so a literal reading is unwinnable. Treated here
# as "50 grazes survived in one flight" instead, since a run only ever ends
# in one crash, making that equivalent to a no-crash streak.
const ACHIEVEMENTS := [
	{"id": "first_transmission", "name": "FIRST TRANSMISSION", "desc": "Complete the navigation tutorial protocol.", "reward": 0},
	{"id": "crystal_energy", "name": "CRYSTAL ENERGY", "desc": "Collect 100 Volt Crystals in a single flight.", "reward": 0},
	{"id": "strike_the_tether", "name": "STRIKE THE TETHER", "desc": "Pass 50 obstacles in a single flight without split lock.", "reward": 200},
	{"id": "cyber_master", "name": "CYBER MASTER", "desc": "Unlock all tethers and upgrade modules.", "reward": 0},
]

const MISSION_TEMPLATES := [
	{"type": "grazes_in_run", "label": "Graze %d pillars in a single run", "min": 10, "max": 20},
	{"type": "crystals_in_run", "label": "Collect %d crystals in a single run", "min": 20, "max": 50},
	{"type": "distance_in_run", "label": "Reach %dm distance in a single run", "min": 100, "max": 300},
	{"type": "runs_today", "label": "Complete %d runs today", "min": 3, "max": 5},
	{"type": "quick_snaps_in_run", "label": "Perform %d snap-backs under 0.2s in a single run", "min": 3, "max": 6},
]
const MISSION_REWARD := 100

var crystals: int = 0
var best_score: int = 0
var active_tether: String = DEFAULT_TETHER
var active_core: String = DEFAULT_CORE
var owned_items: Array = [DEFAULT_TETHER, DEFAULT_CORE]
var run_history: Array = []
var colorblind_mode: String = "none"
var music_enabled: bool = true
var haptics_enabled: bool = true
var unlocked_achievements: Array = []
var achievement_progress: Dictionary = {} # id -> best-seen value, for progress bars

var missions_date: String = ""
var missions: Array = [] # [{type, target, label, progress, completed}]
var runs_completed_today: int = 0

func _ready() -> void:
	var data := SaveSystem.load_data()
	if not data.is_empty():
		crystals = data.get("crystals", crystals)
		best_score = data.get("best_score", best_score)
		active_tether = data.get("active_tether", active_tether)
		active_core = data.get("active_core", active_core)
		owned_items = data.get("owned_items", owned_items)
		run_history = data.get("run_history", run_history)
		colorblind_mode = data.get("colorblind_mode", colorblind_mode)
		music_enabled = data.get("music_enabled", music_enabled)
		haptics_enabled = data.get("haptics_enabled", haptics_enabled)
		unlocked_achievements = data.get("unlocked_achievements", unlocked_achievements)
		achievement_progress = data.get("achievement_progress", achievement_progress)
		missions_date = data.get("missions_date", missions_date)
		missions = data.get("missions", missions)
		runs_completed_today = data.get("runs_completed_today", runs_completed_today)
	_ensure_daily_missions()

func add_crystals(amount: int) -> void:
	crystals += amount
	crystals_changed.emit(crystals)

## Buys a crystal-priced catalog item. Returns true on success. Callers must
## check `currency` themselves before calling this — real-money items are not
## handled here (see shop_screen.gd's "not available yet" notice).
func buy_item(id: String, price: int) -> bool:
	if owned_items.has(id):
		return false
	if crystals < price:
		return false
	crystals -= price
	owned_items.append(id)
	crystals_changed.emit(crystals)
	save()
	return true

func select_tether(id: String) -> void:
	if owned_items.has(id):
		active_tether = id
		save()

func select_core(id: String) -> void:
	if owned_items.has(id):
		active_core = id
		save()

func has_upgrade(id: String) -> bool:
	return owned_items.has(id)

func complete_tutorial() -> void:
	_unlock_achievement("first_transmission")
	save()

## Called once per run on crash. `stats` keys: distance, crystals, grazes,
## quick_snaps (snap-backs under 0.2s).
func record_run(stats: Dictionary) -> void:
	var distance: int = stats.get("distance", 0)
	if distance > best_score:
		best_score = distance

	run_history.append(distance)
	if run_history.size() > 20:
		run_history.pop_front()

	_ensure_daily_missions()
	runs_completed_today += 1

	var run_crystals: int = stats.get("crystals", 0)
	var run_grazes: int = stats.get("grazes", 0)
	var run_quick_snaps: int = stats.get("quick_snaps", 0)

	_bump_progress("crystal_energy", run_crystals)
	if run_crystals >= 100:
		_unlock_achievement("crystal_energy")

	_bump_progress("strike_the_tether", run_grazes)
	if run_grazes >= 50:
		_unlock_achievement("strike_the_tether")

	if _all_catalog_owned():
		_unlock_achievement("cyber_master")

	for m in missions:
		match m.type:
			"grazes_in_run":
				m.progress = max(m.progress, run_grazes)
			"crystals_in_run":
				m.progress = max(m.progress, run_crystals)
			"distance_in_run":
				m.progress = max(m.progress, distance)
			"quick_snaps_in_run":
				m.progress = max(m.progress, run_quick_snaps)
			"runs_today":
				m.progress = runs_completed_today
		if not m.completed and m.progress >= m.target:
			m.completed = true
			add_crystals(MISSION_REWARD)

	save()

func _all_catalog_owned() -> bool:
	for entry in TETHER_CATALOG:
		if not owned_items.has(entry.id):
			return false
	for entry in CORE_CATALOG:
		if not owned_items.has(entry.id):
			return false
	return true

func _bump_progress(achievement_id: String, value: int) -> void:
	var current: int = achievement_progress.get(achievement_id, 0)
	if value > current:
		achievement_progress[achievement_id] = value

func _unlock_achievement(id: String) -> void:
	if unlocked_achievements.has(id):
		return
	unlocked_achievements.append(id)
	for entry in ACHIEVEMENTS:
		if entry.id == id and entry.reward > 0:
			add_crystals(entry.reward)

func _ensure_daily_missions() -> void:
	var today := Time.get_date_string_from_system()
	if today == missions_date and missions.size() == 3:
		return

	missions_date = today
	runs_completed_today = 0
	missions = []

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(today)
	var indices: Array = range(MISSION_TEMPLATES.size())
	# Manual Fisher-Yates using the date-seeded rng (Array.shuffle() always
	# draws from the engine's global RNG, so it can't be seeded this way) —
	# keeps the day's mission set stable across restarts.
	for i in range(indices.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp

	var picked := indices.slice(0, 3)
	for idx in picked:
		var tmpl: Dictionary = MISSION_TEMPLATES[idx]
		var target: int = rng.randi_range(tmpl.min, tmpl.max)
		missions.append({
			"type": tmpl.type,
			"target": target,
			"label": tmpl.label % target,
			"progress": 0,
			"completed": false,
		})

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
		"unlocked_achievements": unlocked_achievements,
		"achievement_progress": achievement_progress,
		"missions_date": missions_date,
		"missions": missions,
		"runs_completed_today": runs_completed_today,
	})
