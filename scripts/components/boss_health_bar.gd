extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $NameLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_boss(boss_name: String, portrait_texture: Texture2D, current: int, max_hp: int) -> void:
	visible = true
	name_label.text = boss_name
	portrait.texture = portrait_texture
	progress_bar.max_value = max_hp
	progress_bar.value = current

func update_health(current: int, max_hp: int) -> void:
	progress_bar.value = current
	progress_bar.max_value = max_hp

func hide_boss() -> void:
	await get_tree().create_timer(2.0).timeout
	visible = false
