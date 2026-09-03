extends CharacterBody2D

@onready var animated_spite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitBox = $AnimatedSprite2D/Hitbox

@onready var detect_hero_area: Area2D = $Detect_Hero
@onready var detect_hero = $Detect_Hero/CollisionShape2D
@onready var detect_dialogue = $DialogueDetection/CollisionShape2D

@export var stats: EnemyData

const ATTACK_START_FRAME := 4
const ATTACK_END_FRAME := 6

var enemy_health: int
var attack_range: float 

var speed: float
var patrol_distance: float

var start_x: float

enum State { IDLE, THROW, MELEE, CHASE, HURT, DEAD }
var current_state = State.IDLE

const JUMP_VELOCITY = -400.0

var MELEE_RANGE
var THROW_RANGE := 100.0

var is_active := false
var is_attacking := false
var isDialog = false
var is_hurt = false
var is_dead = false
var main_player: CharacterBody2D = null
var main_player_animated_sprite

func _ready() -> void:
	detect_hero.disabled = true
	detect_dialogue.disabled = false
	is_active = false
	MELEE_RANGE = stats.attack_range
	
	enemy_health = stats.max_health
	speed = stats.speed
	patrol_distance = stats.patrol_distance
	attack_range = stats.attack_range
	
	if stats.sprite_frames:
		animated_spite_2d.sprite_frames = stats.sprite_frames
	
	hitbox.damage = stats.attack_damage
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	if is_dead or not is_active:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta	
	
	
	match current_state:
		State.CHASE:
			enemy_chase()
		State.THROW:
			throw_attack()
		State.MELEE:
			melee_attack()
		State.IDLE:
			enemy_idle()

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

func enemy_idle():
	if main_player == null:
		return
	
	velocity.x = 0
	animated_spite_2d.play("idle")

func enemy_chase():
	if main_player == null or not is_player_in_detection_zone():
		main_player = null
		velocity.x = 0
		current_state = State.IDLE
		return
	
	var distance = abs(main_player.global_position.x - global_position.x)
	var direction_enemy = sign(main_player.global_position.x - global_position.x) # встроенная математическая функция, которая возвращает -1, если число отрицательное, 1, если положительное, и 0, если число равно нулю.
	set_facing(direction_enemy)
	
	if distance < MELEE_RANGE:
		velocity.x = 0
		current_state = State.MELEE
		return
	elif distance < THROW_RANGE:
		velocity.x = 0
		current_state = State.THROW
		return
	
	velocity.x = direction_enemy * speed

func melee_attack():
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	animated_spite_2d.play("attack_leg")
	await animated_spite_2d.animation_finished
	is_attacking = false
	
	if is_player_in_detection_zone():
		current_state = State.CHASE
	else:
		main_player = null
		current_state = State.IDLE
	
func throw_attack():
	if is_attacking:
		return
	
	is_attacking = true
	velocity.x = 0
	
	
	animated_spite_2d.play("attack_rock")
	# сюда позже добавишь instantiate/tween камня, привязанный к нужному frame_changed
	await animated_spite_2d.animation_finished
	is_attacking = false
	
	if is_player_in_detection_zone():
		current_state = State.CHASE
	else:
		main_player = null
		current_state = State.IDLE

func is_player_in_detection_zone() -> bool:
	var bodies = detect_hero_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("main_player"):
			return true
	return false

func _on_dialogue_detection_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	main_player = body
	main_player_animated_sprite = body.get_node("AnimatedSprite2D") as AnimatedSprite2D
	
	if not isDialog:
		main_player.is_frozen = true
		#main_player.velocity = Vector2.ZERO
		main_player_animated_sprite.play("idle")
		
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Dialogic.start("timeline")
		Dialogic.timeline_ended.connect(_on_dialogic_end, CONNECT_ONE_SHOT)

func _on_dialogic_end():
	main_player.is_frozen = false
	detect_hero.disabled = false
	detect_dialogue.disabled = true
	
	main_player = null
	activate()
	#main_player.velocity = Vector2

func activate():
	is_active = true
	isDialog = false #del
	
	var bodies = detect_hero_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("main_player"):
			main_player = body
			current_state = State.CHASE
			return
	
	current_state = State.IDLE

func _on_hurt_box_hurted(value: Variant) -> void:
	if is_dead:
		return
	
	enemy_health -= value
	print("Cyclops HP =", enemy_health)
	
	if enemy_health <= 0:
		die()
		return
	
	is_hurt = true
	animated_spite_2d.play("hurt")
	await animated_spite_2d.animation_finished
	is_hurt = false

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_spite_2d.play("die")
	Dialogic.VAR.CiclopusFall = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
	Dialogic.start("kill_boss_cave")
	main_player.is_frozen = true
	Dialogic.timeline_ended.connect(_on_dialogic_end_cyclop_die)


func _on_dialogic_end_cyclop_die():
	main_player.is_frozen = false

func _on_detect_hero_body_entered(body: Node2D) -> void:
	if body.is_in_group("main_player"):
		main_player = body
		current_state = State.CHASE


func _on_detect_hero_body_exited(body: Node2D) -> void:
	if body.is_in_group("main_player") or body == main_player:
		main_player = null
		velocity.x = 0
		current_state = State.IDLE


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_spite_2d: return
	
	var attackAnimation = animated_spite_2d.animation == "attack_leg"
	var frame = animated_spite_2d.frame

	if attackAnimation:
		if frame == ATTACK_START_FRAME:
			hitbox.set_active(true)
		elif frame == ATTACK_END_FRAME:
			hitbox.set_active(false)
