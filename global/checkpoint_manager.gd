extends Node

var last_checkpoint_position: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

signal checkpoint_activated(position: Vector2)
signal player_respawned

func set_checkpoint(pos: Vector2) -> void:
	last_checkpoint_position = pos
	has_checkpoint = true
	checkpoint_activated.emit(pos)

func reset() -> void:
	has_checkpoint = false
