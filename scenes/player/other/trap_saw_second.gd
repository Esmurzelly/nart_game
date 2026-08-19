extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var hurt_box := body.get_node("HurtBox") as HurtBox
	if hurt_box:
		hurt_box.get_damage(1)
