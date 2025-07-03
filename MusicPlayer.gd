extends Node

var audio_stream_player: AudioStreamPlayer

func _ready():
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.stream = load("res://Music/Echoes of the Machine (Remastered).wav")
	audio_stream_player.play()
