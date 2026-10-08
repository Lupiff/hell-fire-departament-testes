extends Node

var player: AudioStreamPlayer
var tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = AudioStreamPlayer.new()
	add_child(player)

func play(stream: AudioStream, fade_time: float = 1.0) -> void:
	if stream == null:
		stop(fade_time)
		return
	if player.stream == stream and player.playing:
		return

	_kill_tween()
	if player.playing and fade_time > 0.0:
		tween = create_tween()
		tween.tween_property(player, "volume_db", -60.0, fade_time * 0.5)
		await tween.finished

	player.stream = stream
	player.volume_db = -60.0 if fade_time > 0.0 else 0.0
	player.play()

	if fade_time > 0.0:
		_kill_tween()
		tween = create_tween()
		tween.tween_property(player, "volume_db", 0.0, fade_time * 0.5)

func stop(fade_time: float = 0.5) -> void:
	_kill_tween()
	if not player.playing:
		return
	if fade_time <= 0.0:
		player.stop()
		return
	tween = create_tween()
	tween.tween_property(player, "volume_db", -60.0, fade_time)
	tween.tween_callback(player.stop)

func _kill_tween() -> void:
	if tween:
		tween.kill()
