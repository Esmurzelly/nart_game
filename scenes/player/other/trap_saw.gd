extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var health_component := body.get_node("HurtBox/HealthComponent") as HealthComponent
	
	if health_component:
		health_component.take_damage(1)
