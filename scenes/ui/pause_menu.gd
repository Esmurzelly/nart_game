extends Control

@onready var resume_button: Button = $ResumeButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitToMenuButton
@onready var settings_panel: Control = $SettingsPanel
@export var menu_music: AudioStream

signal resume_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_panel.visible = false
	AudioManager.play_music(menu_music, 0.3)
	
	resume_button.pressed.connect(func(): resume_pressed.emit())
	settings_button.pressed.connect(func(): settings_panel.visible = true)
	quit_button.pressed.connect(_on_quit_to_menu_pressed)
	settings_panel.back_pressed.connect(func(): settings_panel.visible = false)
	
func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
