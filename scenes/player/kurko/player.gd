extends CharacterBody2D

var is_attacking = false
var is_hurt = false
var is_dead = false

@export var max_health := 10
@export var player_health := max_health

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
var jump_count: int = 0

const ATTACK_START_FRAME := 4
const ATTACK_END_FRAME := 6

@onready var hitbox: HitBox = $AnimatedSprite2D/Hitbox2
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var can_move = true
var can_take_damage = true

func _physics_process(delta: float) -> void:
	if is_attacking or is_hurt: #???
		move_and_slide()
		return
		
	if not is_on_floor(): # gravity
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and jump_count < 1: # jump
		jump_count += 1
		velocity.y = JUMP_VELOCITY
	
	if is_on_floor(): #jump count
		jump_count = 0

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		attack()
		return
	
	_set_animation()
	
func _on_attack_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D/Hitbox/CollisionShape2D.disabled = true


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: return
	
	var attackAnimation = animated_sprite_2d.animation == "attack"
	var frame = animated_sprite_2d.frame
	
	if attackAnimation:
		if frame == ATTACK_START_FRAME:
			hitbox.set_active(true)
		elif frame == ATTACK_END_FRAME:
			hitbox.set_active(false)

func attack():
	if is_attacking:
		return
	
	is_attacking = true
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	hitbox.set_active(false)
	is_attacking = false
	
func _set_animation():
	if is_attacking or is_dead or is_hurt:
		return
	
	if velocity.x != 0:
		animated_sprite_2d.play("run")

		if velocity.x > 0:
			#anim.flip_h = false
			animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x) # 1
		else:
			#anim.flip_h = true
			animated_sprite_2d.scale.x = -abs(animated_sprite_2d.scale.x) # -1
				
	else:
		animated_sprite_2d.play("idle")


func _on_hurt_box_hurted(value) -> void:
	if !can_take_damage or is_dead:
		return
	
	can_take_damage = false
	player_health -= value
	print("HP =", player_health)
	
	if player_health <= 0:
		die()
		return
	
	is_hurt = true
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	is_hurt = false
	
	await get_tree().create_timer(0.3).timeout
	can_take_damage = true

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite_2d.play("idle") #change the animation
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://levels/act_01/cave/cave.tscn")
