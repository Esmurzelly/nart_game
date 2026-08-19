extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_small: CollisionShape2D = $HitboxSmall
@onready var hitbox_medium: CollisionShape2D = $HitboxMedium

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_small.disabled = true
	hitbox_medium.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var hurt_box := body.get_node("HurtBox") as HurtBox
	if hurt_box:
		hurt_box.get_damage(1)


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	if animated_sprite_2d.animation != "on": return
	
	var frame = animated_sprite_2d.frame
	
	hitbox_small.disabled = not (frame >= 1 and frame <= 5)
	hitbox_medium.disabled = not (frame >= 6 and frame <= 9)
	


func _on_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.play("on")


func _on_detection_body_exited(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.stop()
