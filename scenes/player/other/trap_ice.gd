extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbox_common: CollisionShape2D = $CollisionShape2D
@onready var hitbox_1: CollisionShape2D = $hitbox_1
@onready var hitbox_2: CollisionShape2D = $hitbox_2
@onready var hitbox_3: CollisionShape2D = $hitbox_3
@onready var hitbox_4: CollisionShape2D = $hitbox_4

var hit_shapes := {}  # запоминаем, какие формы уже нанесли урон в этом цикле

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	
	hitbox_common.disabled = true
	hitbox_1.disabled = true
	hitbox_2.disabled = true
	hitbox_3.disabled = true
	hitbox_4.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_body_entered(body: CharacterBody2D) -> void:
	#pass 
	
	#if not body.is_in_group("main_player"):
	#	return
	
	#var hurt_box := body.get_node("HurtBox") as HurtBox
	#if hurt_box:
	#	hurt_box.get_damage(1)


func _on_detection_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	animated_sprite_2d.play("on")
	
	if body.has_method("freeze"):
		await get_tree().create_timer(0.1).timeout
		var anim_length = $AnimationPlayer.get_animation("damage").length
		body.freeze(anim_length)
	
	$AnimationPlayer.play("damage")
	
	await get_tree().create_timer(6.2).timeout
	queue_free()


func _on_detection_body_exited(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	hit_shapes.clear()
	
	animated_sprite_2d.stop()
	$AnimationPlayer.stop()


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	if animated_sprite_2d.animation != "on": return
	
	var frame = animated_sprite_2d.frame
	
	hitbox_common.disabled = not (frame >= 2)
	hitbox_1.disabled = not (frame >= 14)
	hitbox_2.disabled = not (frame >= 16)
	hitbox_3.disabled = not (frame >= 18)
	hitbox_4.disabled = not (frame >= 20)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if not body.is_in_group("main_player"):
		return
	
	if hit_shapes.has(local_shape_index):
		return  # эта конкретная форма уже наносила урон, не бьём повторно
	
	hit_shapes[local_shape_index] = true
	
	var hurt_box := body.get_node("HurtBox") as HurtBox
	if hurt_box:
		hurt_box.get_damage(1)
