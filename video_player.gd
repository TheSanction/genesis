extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.play()
	video_player.finished.connect(on_video_finished)

func on_video_finished():
	get_tree().change_scene_to_file("res://main.tscn")
