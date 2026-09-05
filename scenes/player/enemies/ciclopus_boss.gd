extends CharacterBody2D

signal boss_activated(boss_name: String, portrait: Texture2D, current: int, max_hp: int)
signal health_changed(current, max_hp)
signal boss_died

@onready var animated_spite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: HitBox = $AnimatedSprite2D/Hitbox

@onready var detect_hero_area: Area2D = $Detect_Hero
@onready var detect_hero = $Detect_Hero/CollisionShape2D
@onready var detect_dialogue = $DialogueDetection/CollisionShape2D

@export var stats: EnemyData

@export var rock_scene: PackedScene
const THROW_SPAWN_FRAME := 10
var rock_thrown_this_attack := false

var throw_target_pos: Vector2

@onready var rock_spawn_point: Marker2D = $RockSpawnPoint

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

var can_react_to_hit := true

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
	
	if is_hurt or is_attacking:
		move_and_slide()
		return
	
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
	rock_thrown_this_attack = false
	
	throw_target_pos = main_player.global_position if main_player else global_position
	
	animated_spite_2d.play("attack_rock")
	await animated_spite_2d.animation_finished
	is_attacking = false
	
	if is_player_in_detection_zone():
		current_state = State.CHASE
	else:
		main_player = null
		current_state = State.IDLE

func throw_rock_at_target(target_pos: Vector2) -> void:
	if not rock_scene:
		return
	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)
	rock.global_position = rock_spawn_point.global_position
	
	var flight_duration := 0.6
	var arc_height := 2.0
	var from_pos = rock.global_position
	
	var tween = create_tween()
	rock.flight_tween = tween
	#tween.tween_property(rock, "global_position", target_pos, flight_duration)
	tween.tween_method(
		func(t: float):
			var pos = from_pos.lerp(target_pos, t)
			pos.y -= sin(t * PI) * arc_height
			rock.global_position = pos,
		0.0, 1.0, flight_duration
	)
	tween.tween_callback(func():
		if is_instance_valid(rock):
			rock.queue_free()  # если не попал за время полёта — убираем сам
	)

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
	isDialog = false
	
	boss_activated.emit(stats.boss_display_name, stats.boss_portrait, enemy_health, stats.max_health)
	health_changed.emit(enemy_health, stats.max_health)
	
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
	health_changed.emit(enemy_health, stats.max_health)
	
	if enemy_health <= 0:
		die()
		return
	
	if is_attacking:
		return
		
	if not can_react_to_hit:
		return
	
	can_react_to_hit = false
	AudioManager.play_sfx(stats.hurt_sound, global_position)
	is_hurt = true
	animated_spite_2d.play("hurt")
	await animated_spite_2d.animation_finished
	is_hurt = false
	
	await get_tree().create_timer(stats.hurt_cooldown).timeout
	can_react_to_hit = true

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	AudioManager.play_sfx(stats.death_sound, global_position)
	boss_died.emit()
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
	
	var attackAnimationLeg = animated_spite_2d.animation == "attack_leg"
	var attackAnimationRock = animated_spite_2d.animation == "attack_rock"
	var frame = animated_spite_2d.frame

	if attackAnimationLeg:
		if frame == ATTACK_START_FRAME:
			hitbox.set_active(true)
		elif frame == ATTACK_END_FRAME:
			hitbox.set_active(false)
			
	elif attackAnimationRock:
		if frame == THROW_SPAWN_FRAME and not rock_thrown_this_attack:
			rock_thrown_this_attack = true
			throw_rock_at_target(throw_target_pos)
