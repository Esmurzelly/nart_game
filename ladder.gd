extends Node2D
class_name Ladder

@onready var top_marker: Marker2D = $TopMarker
@onready var bottom_marker: Marker2D = $BottomMarker

var player: CharacterBody2D = null
var player_at_bottom := false
var player_at_top := false

func _on_bottom_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("main_player"):
		player = body
		player_at_bottom = true
		print('Entered bottom')


func _on_bottom_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("main_player"):
		player_at_bottom = false
		print('Exited bottom')


#func _on_top_zone_body_entered(body: Node2D) -> void:
#	if body.is_in_group("main_player"):
#		player = body
#		player_at_top = true
#		print('Entered top')


#func _on_top_zone_body_exited(body: Node2D) -> void:
	#if body.is_in_group("main_player"):
	#	player_at_top = false
	#	print('Exited top')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Input.is_action_just_pressed("ladder_move"):
		return
	
	if player_at_bottom:
		player.climb_ladder(bottom_marker.global_position, top_marker.global_position)
	elif player_at_top:
		player.climb_ladder(top_marker.global_position, bottom_marker.global_position)
