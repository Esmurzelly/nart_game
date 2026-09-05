extends Control

@onready var music_slider: HSlider = $TabContainer/Audio/MusicSlider
@onready var sfx_slider: HSlider = $TabContainer/Audio/SFXSlider
@onready var back_button: Button = $BackButton

signal back_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(func(): back_pressed.emit())

func _on_music_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_sfx_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
