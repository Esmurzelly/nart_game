extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var activate_sound: AudioStream

var is_activated := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CheckpointManager.checkpoint_activated.connect(_on_any_checkpoint_activated)
	animated_sprite_2d.stop()


func _on_any_checkpoint_activated(pos: Vector2) -> void:
	if pos != global_position and is_activated:
		is_activated = false
		animated_sprite_2d.stop()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	if is_activated:
		return
	
	print('entered', body)
	is_activated = true
	CheckpointManager.set_checkpoint(global_position)
	AudioManager.play_sfx(activate_sound, global_position)
	animated_sprite_2d.play("on")
