extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var hurt_box := body.get_node("HurtBox") as HurtBox
	if hurt_box:
		hurt_box.get_damage(1)
	
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.play("on")


func _on_detection_body_exited(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.stop()
	$CollisionShape2D.disabled = true


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	if animated_sprite_2d.animation != "on": return
	
	var frame = animated_sprite_2d.frame
	
	$CollisionShape2D.disabled = not (frame >= 1)
