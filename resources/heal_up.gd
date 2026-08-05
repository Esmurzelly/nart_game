extends Area2D
class_name HealBox

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	var health_component := body.get_node("HurtBox/HealthComponent") as HealthComponent
	
	if health_component:
		health_component.heal(1)

	
	await get_tree().create_timer(0.3).timeout
	queue_free()
