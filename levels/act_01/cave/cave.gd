extends Node2D

@onready var player: CharacterBody2D = $Player2
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	progress_bar.subscribe(player.health_component)
