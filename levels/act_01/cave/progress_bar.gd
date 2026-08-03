extends ProgressBar

func subscribe(health_component: HealthComponent) -> void:
	health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(health_component.current_health, health_component.max_health)

func _on_health_changed(current: int, max_hp: int) -> void:
	value = current
	max_value = max_hp
