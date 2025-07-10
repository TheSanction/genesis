extends Control

func _ready():
	GlobalUI.hide()
	$VBoxContainer/StartButton.pressed.connect(on_start_pressed)
	$VBoxContainer/ArisButton.pressed.connect(on_aris_pressed)
	$VBoxContainer/AlistarButton.pressed.connect(on_alistar_pressed)
	$VBoxContainer/NathanButton.pressed.connect(on_nathan_pressed)
	$VBoxContainer/TestButton.pressed.connect(on_test_pressed)
	$VBoxContainer/EyeAnimationButton.pressed.connect(on_eye_animation_pressed)
	$VBoxContainer/NNButton.pressed.connect(on_nn_pressed)

func on_start_pressed():
	Global.selected_intro = "genesis"
	get_tree().change_scene_to_file("res://main.tscn")

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

func on_nn_pressed():
	var puzzle_scene = load("res://NetworkPuzzle.tscn").instantiate()
	get_tree().get_root().add_child(puzzle_scene)
	var random_width = randi_range(4, 6)
	var random_height = randi_range(3, 6)
	puzzle_scene.initialize(random_width, random_height) # Initialize with a random grid size
	self.hide() # Hide the splash screen
