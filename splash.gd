extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(on_start_pressed)
	$VBoxContainer/ArisButton.pressed.connect(on_aris_pressed)
	$VBoxContainer/AlistarButton.pressed.connect(on_alistar_pressed)
	$VBoxContainer/NathanButton.pressed.connect(on_nathan_pressed)
	$VBoxContainer/TestButton.pressed.connect(on_test_pressed)
	$VBoxContainer/EyeAnimationButton.pressed.connect(on_eye_animation_pressed)

func on_start_pressed():
	Global.selected_intro = "genesis"
	get_tree().change_scene_to_file("res://video_player.tscn")

func on_aris_pressed():
	Global.selected_intro = "aris"
	Global.video_to_play = "res://Video/aris_start_work.ogv"
	get_tree().change_scene_to_file("res://video_player.tscn")

func on_alistar_pressed():
	Global.selected_intro = "alistar"
	Global.video_to_play = "res://Video/alistar_start_work.ogv"
	get_tree().change_scene_to_file("res://video_player.tscn")

func on_nathan_pressed():
	Global.selected_intro = "nathan"
	Global.video_to_play = "res://Video/nathan_start_work.ogv"
	get_tree().change_scene_to_file("res://video_player.tscn")

func on_test_pressed():
	Global.selected_intro = "test"
	get_tree().change_scene_to_file("res://main.tscn")

func on_eye_animation_pressed():
	get_tree().change_scene_to_file("res://eye_animation.tscn")
