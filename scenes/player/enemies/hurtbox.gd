extends Area2D

@export var health := 30

@onready var anim = $"../AnimatedSprite2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

"""
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		print("hit")
		anim.play("hurt")
		await get_tree().create_timer(0.5).timeout
		anim.play("attack")
		health -= 10
	
	if health <= 0:
		anim.play("die")
		await get_tree().create_timer(2.0).timeout
		get_parent().queue_free()
"""
