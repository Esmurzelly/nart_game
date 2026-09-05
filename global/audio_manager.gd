extends Node
var music_player: AudioStreamPlayer
var current_music: AudioStream
var music_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)

func play_music(stream: AudioStream, fade_time: float = 0.5) -> void:
	print("=== play_music called ===")
	print("requested stream: ", stream)
	print("current_music: ", current_music)
	print("music_player.playing: ", music_player.playing)
	print("music_player.stream_paused: ", music_player.stream_paused)
	print("tree.paused: ", get_tree().paused)
	
	if not stream:
		print("EXIT: stream is null")
		return
	if current_music == stream and music_player.playing:
		print("EXIT: same stream already playing")
		return
	
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	
	if music_tween and music_tween.is_valid():
		print("killing previous tween")
		music_tween.kill()
	
	current_music = stream
	
	if music_player.playing:
		print("branch: crossfade (was playing)")
		music_tween = create_tween()
		music_tween.tween_property(music_player, "volume_db", -40.0, fade_time)
		music_tween.tween_callback(func():
			print("callback fired: switching stream to ", stream)
			music_player.stream = stream
			music_player.volume_db = -40.0
			music_player.play()
		)
		music_tween.tween_property(music_player, "volume_db", -10.0, fade_time)
	else:
		print("branch: fresh play (was not playing)")
		music_player.stream = stream
		music_player.volume_db = -40.0
		music_player.play()
		music_tween = create_tween()
		music_tween.tween_property(music_player, "volume_db", -10.0, fade_time)

func stop_music(fade_out: float = 0.5) -> void:
	if music_tween and music_tween.is_valid():
		music_tween.kill()
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", -40.0, fade_out)
	music_tween.tween_callback(music_player.stop)

func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if not stream:
		return
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = stream
	sfx.bus = "SFX"
	sfx.global_position = position
	sfx.volume_db = volume_db
	get_tree().current_scene.add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)
