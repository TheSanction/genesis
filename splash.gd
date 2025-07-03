extends Control

func _ready():
	$Button.pressed.connect(on_button_pressed)

func on_button_pressed():
	get_tree().change_scene_to_file("res://video_player.tscn")
