extends Area2D

func _on_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var hurt_box := body.get_node("HurtBox") as HurtBox
	if hurt_box:
		hurt_box.get_damage(1)
