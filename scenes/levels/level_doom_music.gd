extends Node

@export var level_music: AudioStream   # deixa vazio = fase sem trilha

func _ready() -> void:
	MusicManager.play(level_music)
