## Preview launcher. Command line (after "--"): --demo=robot | --demo=zombie | --demo=soccer
extends Node
var scene: Node
func _ready() -> void:
	var which := "robot"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--demo="):
			which = a.split("=")[1]
	Kit.library()
	var scripts := {"zlineup": "res://scripts/ZLineup.gd", "probe": "res://scripts/Probe.gd", "bake": "res://scripts/Bake.gd", "anim_sheet": "res://scripts/AnimSheet.gd", "stage_tokyo": "res://scripts/StageShot.gd", "stage_egypt": "res://scripts/StageShot.gd", "stage_nyc": "res://scripts/StageShot.gd", "shape": "res://scripts/ShapeCompare.gd", "robot_clip2": "res://scripts/RobotClip2.gd", "rt_test": "res://scripts/RetargetTest.gd", "robot_clip": "res://scripts/RobotClip.gd", "shot_zombie": "res://scripts/ShotZombie.gd", "shot_soccer": "res://scripts/ShotSoccer.gd", "shot_robot": "res://scripts/ShotRobot.gd", "robot": "res://scripts/RobotScene.gd", "zombie": "res://scripts/ZombieScene.gd", "soccer": "res://scripts/SoccerScene.gd"}
	scene = Node3D.new()
	scene.set_script(load(scripts[which]))
	add_child(scene)
	scene.setup(true)
	scene.finished.connect(func(): get_tree().quit())
