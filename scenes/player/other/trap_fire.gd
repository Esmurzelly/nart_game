extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
const ACTIVATE_FRAME := 4
const DEACTIVATE_FRAME := 6

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


func _on_detection_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.play("on")


func _on_detection_body_exited(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.stop()


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	if animated_sprite_2d.animation != "on": return
	
	var frame = animated_sprite_2d.frame
	
	if frame == ACTIVATE_FRAME: #4
		$CollisionShape2D.disabled = false
	elif frame == DEACTIVATE_FRAME: #6
		$CollisionShape2D.disabled = true
