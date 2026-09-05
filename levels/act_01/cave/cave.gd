extends Node2D

@onready var main_player: CharacterBody2D = $Player2
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar

@onready var boss: CharacterBody2D = $CiclopusBoss
@onready var boss_health_bar: Control = $CanvasLayer/BossHealthBar

@export var level_music: AudioStream
@export var boss_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(level_music)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	progress_bar.subscribe(main_player.health_component)
	
	boss.boss_activated.connect(_on_boss_activated)
	boss.health_changed.connect(boss_health_bar.update_health)
	boss.boss_died.connect(_on_cyclops_died)

	Dialogic.start("start_cave")
	main_player.is_frozen = true
	Dialogic.timeline_ended.connect(_on_dialogic_end, CONNECT_ONE_SHOT)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument): # функция принимает аргументы, который мы кидается из самого диалога
	if argument == 'accept':
		print("accept from dialogue_signal")
		Dialogic.start("kill_boss_cave")
		main_player.is_frozen = true
		Dialogic.timeline_ended.connect(_on_dialogic_end)
		

func _on_dialogic_end():
	main_player.is_frozen = false
	

func _on_boss_activated(boss_name: String, portrait: Texture2D, current: int, max_hp: int) -> void:
	boss_health_bar.show_boss(boss_name, portrait, current, max_hp)
	AudioManager.play_music(boss_music, 1.0)

func _on_cyclops_health_changed(current: int, max_hp: int) -> void:
	boss_health_bar.update_health(current, max_hp)

func _on_cyclops_died() -> void:
	boss_health_bar.hide_boss()
	AudioManager.play_music(level_music, 2.0)
