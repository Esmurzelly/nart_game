extends Control

@onready var play_button: Button = $PlayButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton
@onready var settings_panel: Control = $SettingsPanel

@export var menu_music: AudioStream
@export var first_level_path: String = "res://levels/act_01/cave/cave.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_panel.visible = false
	AudioManager.play_music(menu_music)
	
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.back_pressed.connect(_on_settings_back)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(first_level_path)

func _on_settings_pressed() -> void:
	settings_panel.visible = true

func _on_settings_back() -> void:
	settings_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
