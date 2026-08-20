extends Node2D

@onready var main_player: CharacterBody2D = $Player2
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	progress_bar.subscribe(main_player.health_component)
	
	Dialogic.start("start_cave")
	main_player.is_frozen = true
	Dialogic.timeline_ended.connect(_on_dialogic_end)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument): # функция принимает аргументы, который мы кидается из самого диалога
	if argument == 'accept':
		print("accept from dialogue_signal")
		Dialogic.start("kill_boss_cave")
		main_player.is_frozen = true
		Dialogic.timeline_ended.connect(_on_dialogic_end)
		

func _on_dialogic_end():
	main_player.is_frozen = false
