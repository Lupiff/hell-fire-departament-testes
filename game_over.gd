extends CanvasLayer

@onready var restart_button: Button = $Control/Button
@export var music: AudioStream
@export var death_sound: AudioStream     # efeito de "morreu" (coração quebrando, etc.)
@export var music_delay: float = 1.5     # quanto tempo depois do som a música entra

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)

	# corta a trilha da fase rápido e toca o efeito na hora
	MusicManager.stop(0.2)
	_play_death_sound()

	# deixa o efeito respirar antes da música do Game Over entrar
	await get_tree().create_timer(music_delay).timeout
	if not is_inside_tree():
		return   # o jogador já reiniciou durante a espera
	MusicManager.play(music)
	
func _play_death_sound() -> void:
	if death_sound == null:
		return
	var sfx := AudioStreamPlayer.new()
	add_child(sfx)
	sfx.stream = death_sound
	sfx.play()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
