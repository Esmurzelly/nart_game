extends RigidBody2D

@export var max_health: int = 100
@export var health: int
var is_dead: bool = false

@export var speed: float = 100.0
var direction: int = -1 # -1 = влево, 1 = вправо

@export var patrol_distance: float = 100.0
var start_x: float


func _ready() -> void:
	health = max_health
	start_x = global_position.x
	
	print(start_x)
	
	
func _physics_process(delta: float) -> void:
	enemy_patrol()
	
	
	if health <= 0:
		die()

func take_damage(damage:int) -> void:
	if is_dead:
		return
		
	health -= damage
	
	print("Golem HP: ", health)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	
	queue_free()

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
