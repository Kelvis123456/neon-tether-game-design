extends RefCounted

## Small factory helpers so each screen script doesn't repeat the same
## Label/Button/ColorRect boilerplate. No custom Theme resource — colors are
## applied per-node, which is enough to read as "Neon Tether" without the
## extra effort of a full StyleBox-based theme.
##
## Not a `class_name` global on purpose: that requires Godot's script-class
## cache, which is only built after the project has been opened/scanned in
## the editor at least once. Callers `preload()` this file instead, which
## works regardless of whether that scan has ever happened.

const CYAN := Color("#00f0ff")
const MAGENTA := Color("#ff007f")
const GREEN := Color("#39ff14")
const ORANGE := Color("#ffaa00")
const BG_DARK := Color("#070710")
const BG_DARKER := Color("#040409")

static func bg(color: Color = BG_DARKER) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

## `wrap: true` is for genuine paragraph/description text with a fixed
## custom_minimum_size set by the caller afterward. Left off by default:
## a wrapping Label reports a much smaller *minimum* size to its parent
## container than its natural single-line width, so a short "badge" label
## (a status tag, a price) with no explicit size can get squeezed down to a
## sliver by a wider sibling and wrap into an unreadable vertical stack —
## found live via the in-engine screenshot test on the achievements screen's
## reward tag.
static func label(text: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func button(text: String, w: float = 200.0, h: float = 56.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(w, h)
	return b

## Standard back-button + centered title bar, full width, pinned to the top.
static func header(title: String, on_back: Callable) -> Control:
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, 64)
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)

	var back := button("< BACK", 90, 44)
	back.position = Vector2(8, 10)
	back.pressed.connect(on_back)
	bar.add_child(back)

	var title_label := label(title, 20, CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.custom_minimum_size = Vector2(450, 44)
	title_label.position = Vector2(0, 12)
	bar.add_child(title_label)

	return bar
