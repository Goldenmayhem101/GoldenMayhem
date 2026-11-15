## Sound effects and music (autoload).
extends Node

var streams := {}
var pool: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var sfx_volume := 1.0

func _ready() -> void:
	for n in ["hit_light", "hit_heavy", "whoosh", "whoosh_heavy", "jump", "land", "ko", "pickup", "clang", "beep", "go", "dodge", "heal", "charge"]:
		streams[n] = load("res://sfx/%s.wav" % n)
	for i in 14:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	music = AudioStreamPlayer.new()
	var m: AudioStreamWAV = load("res://sfx/music_drums.wav")
	m.loop_mode = AudioStreamWAV.LOOP_FORWARD
	m.loop_end = m.data.size() / 2
	music.stream = m
	music.volume_db = -9.0
	add_child(music)

func play(n: String, vol_db: float = 0.0, pitch_var: float = 0.08) -> void:
	if not streams.has(n):
		return
	for p in pool:
		if not p.playing:
			p.stream = streams[n]
			p.volume_db = vol_db + linear_to_db(sfx_volume)
			p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
			p.play()
			return

func start_music() -> void:
	if not music.playing:
		music.play()

func stop_music() -> void:
	music.stop()
