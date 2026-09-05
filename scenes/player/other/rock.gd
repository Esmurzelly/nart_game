extends Area2D

@export var damage: int = 1
var flight_tween: Tween

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		area.get_damage(damage)
		if flight_tween:
			flight_tween.kill()  # немедленно останавливаем Tween
		queue_free()
