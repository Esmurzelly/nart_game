extends Area2D
class_name HurtBox

signal hurted(value)

@export var health_component: HealthComponent

func get_damage(value: int):
	if health_component:
		health_component.take_damage(value)
	
	hurted.emit(value) # signal for animation
