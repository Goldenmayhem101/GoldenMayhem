extends Node
var streams := {}
var pool: Array[AudioStreamPlayer] = []
func _ready() -> void:
	var d := DirAccess.open("res://sfx")
	for f in d.get_files():
		if f.ends_with(".wav"):
			streams[f.get_basename()] = load("res://sfx/" + f)
	for i in 16:
		var p := AudioStreamPlayer.new(); add_child(p); pool.append(p)
func play(n: String, db := 0.0, pv := 0.08) -> void:
	if not streams.has(n): return
	for p in pool:
		if not p.playing:
			p.stream = streams[n]; p.volume_db = db; p.pitch_scale = 1.0 + randf_range(-pv, pv); p.play(); return
func loop(n: String, db := 0.0) -> void:
	var p := AudioStreamPlayer.new(); add_child(p)
	var s: AudioStreamWAV = streams[n].duplicate(); s.loop_mode = AudioStreamWAV.LOOP_FORWARD; s.loop_end = s.data.size() / 2
	p.stream = s; p.volume_db = db; p.play()
