extends Node2D
class_name HealthComponent

@export var max_health := 10
var current_health: int
var is_dead := false

signal health_changed(current, max)
signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		is_dead = true
		died.emit()

func heal(amount: int) -> void:
	if is_dead:
		return
	
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
