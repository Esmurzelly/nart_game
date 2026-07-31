extends RigidBody2D

@onready var animated_spite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_health: int = 100
@export var health: int

@export var speed: float = 100.0
var direction: int = -1 # -1 = влево, 1 = вправо

@export var patrol_distance: float = 100.0
var start_x: float


func _ready() -> void:
	health = max_health
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	enemy_patrol()

func enemy_patrol():
	var distance_from_start = global_position.x - start_x
	
	if direction == -1 and distance_from_start <= -patrol_distance:
		direction = 1
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
	elif direction == 1 and distance_from_start >= patrol_distance:
		direction = -1
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walk")
		
	linear_velocity.x = direction * speed


func _on_hurt_box_hurted() -> void:
	animated_spite_2d.play("hurt")

func _on_hurt_box_died() -> void:
	animated_spite_2d.play("die")
	# timer
	queue_free()
