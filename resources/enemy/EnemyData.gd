extends Resource
class_name EnemyData

'''
@export var idle_animation_name: String = "idle"
@export var walk_animation_name: String = "walk"
@export var attack_animation_name: String = "attack"
@export var hurt_animation_name: String = "hurt"
@export var die_animation_name: String = "die"
'''

@export_group("Stats")

@export var enemy_name: String = "Golem"
@export var max_health: int = 3
@export var damage: int = 1
@export var speed: float = 200
@export var patrol_distance: float = 200
@export var attack_damage: int = 1
@export var attack_range: float = 20.0

@export_group("Graphics")

@export var sprite_frames: SpriteFrames


@export_group("Experience")

@export var exp_reward: int = 10
