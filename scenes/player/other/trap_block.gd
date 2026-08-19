extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var solid_collision: CollisionShape2D = $CollisionShape2D

var is_breaking := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solid_collision.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	if animated_sprite_2d.animation != "on": return
	
	var frame = animated_sprite_2d.frame
	
	if animated_sprite_2d.frame >= 3:
		solid_collision.disabled = true


func _on_top_detector_body_entered(body: Node2D) -> void:
	if is_breaking:
		return
	
	if not body.is_in_group("main_player"):
		return
	
	if body.global_position.y >= global_position.y:
		return
	
	start_breaking()
	
func start_breaking() -> void:
	is_breaking = true
	animated_sprite_2d.play("on")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "on":
		await get_tree().create_timer(1).timeout
		queue_free()
