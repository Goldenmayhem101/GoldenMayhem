## Character data: rig extras, stats and signature moves for each warrior.
class_name Chars

const DATA := {
	"hyena": {
		"name": "HYENA", "title": "The Wild Brawler",
		"hip": [480, 1000], "head": [250, 40, 720, 430],
		"tips": {"arm_f_lo": [95, 1040], "arm_b_lo": [820, 1040], "leg_f_lo": [170, 1470], "leg_b_lo": [800, 1470]},
		"weight": 1.0, "run": 440.0, "jump": 900.0,
		"color": Color(0.95, 0.62, 0.22), "signature": "FRENZY",
	},
	"kangaroo": {
		"name": "KANGAROO", "title": "The Kickboxer",
		"hip": [400, 800], "head": [270, 20, 560, 330],
		"tips": {"arm_f_lo": [110, 730], "arm_b_lo": [630, 712], "leg_f_lo": [60, 1430], "leg_b_lo": [720, 1460]},
		"weight": 0.92, "run": 470.0, "jump": 980.0,
		"color": Color(0.85, 0.35, 0.2), "signature": "TAIL KICK",
	},
}

static var _rig: Dictionary = {}

static func rig() -> Dictionary:
	if _rig.is_empty():
		var f := FileAccess.open("res://art/rig.json", FileAccess.READ)
		_rig = JSON.parse_string(f.get_as_text())
	return _rig

static func portrait(id: String) -> AtlasTexture:
	var r: Dictionary = rig()[id]
	var s: float = r.scale
	var b: Dictionary = r.parts.body
	var h: Array = DATA[id].head
	var at := AtlasTexture.new()
	at.atlas = load("res://art/" + b.file)
	at.region = Rect2((h[0] - b.origin[0]) * s, (h[1] - b.origin[1]) * s, (h[2] - h[0]) * s, (h[3] - h[1]) * s)
	return at
