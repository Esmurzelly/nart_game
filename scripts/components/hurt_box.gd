extends Area2D
class_name HurtBox

signal hurted()
signal died()

@export var healthPoint := 3

func get_damage(value: int):
	healthPoint -= value
	
	hurted.emit()
	
	if healthPoint <= 0:
		died.emit()
