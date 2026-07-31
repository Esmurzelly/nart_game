extends Area2D
class_name HurtBox

signal hurted(value)
#signal died()

#@export var healthPoint := 3

func get_damage(value: int):
	#healthPoint -= value
	
	hurted.emit(value)
	
	#if healthPoint <= 0:
		#died.emit()
