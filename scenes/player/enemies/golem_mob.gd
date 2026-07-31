extends CharacterBody2D

@onready var animated_spite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var max_health := 3
@export var enemy_health := max_health
@export var attack_range: float = 20.0

@export var speed: float = 100.0
var direction: int = [-1, 1].pick_random() # -1 = влево, 1 = вправо

@export var patrol_distance: float = 100.0
var start_x: float

var is_attacking = false
var is_hurt = false
var is_dead = false

enum State {
	PATROL,
	CHASE,
	ATTACK
}

var current_state = State.PATROL

var player: CharacterBody2D = null # main hero

const ATTACK_START_FRAME := 6
const ATTACK_END_FRAME := 9

@onready var hitbox: HitBox = $AnimatedSprite2D/Hitbox

func _ready() -> void:
	enemy_health = max_health
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_hurt or is_attacking:
		move_and_slide()
		return
	
	match current_state:
		State.PATROL:
			enemy_patrol()
		State.CHASE:
			enemy_chase()
		State.ATTACK:
			enemy_attack()
	
	move_and_slide()
	_set_animation()
	
func _set_animation() -> void:
	if is_attacking or is_dead or is_hurt:
		return
	
	if velocity.x != 0:
		animated_spite_2d.play("walk")
	else:
		animated_spite_2d.play("idle")
	
func set_facing(dir: int) -> void:
	if dir == 0:
		return
	
	animated_spite_2d.scale.x = abs(animated_spite_2d.scale.x) * dir

func enemy_chase():
	if player == null:
		return
	
	var distance = abs(player.global_position.x - global_position.x)
	var direction_enemy = sign(player.global_position.x - global_position.x) # встроенная математическая функция, которая возвращает -1, если число отрицательное, 1, если положительное, и 0, если число равно нулю.
	set_facing(direction_enemy)
	
	if distance < attack_range:
		velocity.x = 0
		current_state = State.ATTACK
		return
	
	velocity.x = direction_enemy * speed
	

func enemy_patrol():
	var distance_from_start = global_position.x - start_x
	
	if direction == -1 and distance_from_start <= -patrol_distance:
		direction = 1
	elif direction == 1 and distance_from_start >= patrol_distance:
		direction = -1
		
	set_facing(direction)
	velocity.x = direction * speed

func enemy_attack():
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	animated_spite_2d.play("attack")
	await animated_spite_2d.animation_finished
	is_attacking = false
	
	current_state = State.CHASE if player != null else State.PATROL

func _on_hurt_box_hurted(value) -> void:
	if is_dead:
		return
	
	enemy_health -= value
	print("Enemy HP =", enemy_health)
	
	if enemy_health <= 0:
		die()
		return
	
	animated_spite_2d.play("hurt")

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_spite_2d.play("die")
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_detect_hero_body_entered(body: Node2D) -> void:
	if body.is_in_group("main_player"):
		player = body
		current_state = State.CHASE
		
		#if position.x - player.position.x < 2:
			#current_state = State.ATTACK
			#set_facing(sign(player.global_position.x - global_position.x))
			#enemy_attack()


func _on_detect_hero_body_exited(body: Node2D) -> void:
	player = null
	current_state = State.PATROL


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_spite_2d: return
	
	var attackAnimation = animated_spite_2d.animation == "attack"
	var frame = animated_spite_2d.frame

	if attackAnimation:
		if frame == ATTACK_START_FRAME:
			hitbox.set_active(true)
		elif frame == ATTACK_END_FRAME:
			hitbox.set_active(false)
		
