## Sound effects pool + one music/ambience track.
extends Node
var streams := {}
var pool: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var amb: AudioStreamPlayer
func _ready() -> void:
	var d := DirAccess.open("res://sfx")
	for f in d.get_files():
		if f.ends_with(".wav"):
			streams[f.get_basename()] = load("res://sfx/" + f)
	for i in 20:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	music = AudioStreamPlayer.new(); add_child(music)
	amb = AudioStreamPlayer.new(); add_child(amb)
func play(n: String, db := 0.0, pv := 0.08) -> void:
	if not streams.has(n):
		return
	for p in pool:
		if not p.playing:
			p.stream = streams[n]; p.volume_db = db; p.pitch_scale = 1.0 + randf_range(-pv, pv); p.play(); return
func loop(player: AudioStreamPlayer, n: String, db: float) -> void:
	var s: AudioStreamWAV = streams[n].duplicate()
	s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	s.loop_end = s.data.size() / 2
	player.stream = s; player.volume_db = db; player.play()
func start_music(n: String, db := -8.0) -> void:
	loop(music, n, db)
func start_amb(n: String, db := -10.0) -> void:
	loop(amb, n, db)
