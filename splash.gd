extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(on_start_pressed)
	$VBoxContainer/ArisButton.pressed.connect(on_aris_pressed)
	$VBoxContainer/AlistarButton.pressed.connect(on_alistar_pressed)

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
