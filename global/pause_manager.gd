extends CanvasLayer

var pause_menu_scene := preload("res://scenes/ui/pause_menu.tscn")
var pause_menu_instance: Control = null
var previous_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		close_pause_menu()
	else:
		open_pause_menu()

func open_pause_menu() -> void:
	get_tree().paused = true
	previous_music = AudioManager.current_music
	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)
	pause_menu_instance.resume_pressed.connect(close_pause_menu)

func close_pause_menu() -> void:
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
	
	AudioManager.play_music(previous_music, 0.3)
	get_tree().paused = false
