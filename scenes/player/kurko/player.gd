extends CharacterBody2D

var is_attacking = false

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
var jump_count: int = 0

const ATTACK_START_FRAME := 4
const ATTACK_END_FRAME := 6

@onready var hitbox: HitBox = $AnimatedSprite2D/Hitbox2
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var can_move = true

func _physics_process(delta: float) -> void:
	# Если атакуем, не обрабатываем ввод для движения и прыжков
	if is_attacking:
		move_and_slide() # Оставляем гравитацию, если персонаж падает во время удара
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < 1:
		jump_count += 1
		velocity.y = JUMP_VELOCITY
	
	if is_on_floor():
		jump_count = 0

	# Get the input direction and handle the movement/deceleration.
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
	
"""
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		anim.play("attack")
		$AnimatedSprite2D/Hitbox/CollisionShape2D.disabled = false
		# Подключаем встроенный сигнал окончания анимации
		if not anim.animation_finished.is_connected(_on_attack_finished):
			anim.animation_finished.connect(_on_attack_finished)
	
	if not is_attacking:
		if velocity.x != 0:
			anim.play("run")
			
			if velocity.x > 0:
				#anim.flip_h = false
				anim.scale.x = abs(anim.scale.x)
			else:
				#anim.flip_h = true
				anim.scale.x = -abs(anim.scale.x)
		else:
			anim.play("idle")
			
"""
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
			#$AnimatedSprite2D/Hitbox2/CollisionShape2D.disabled = false
			hitbox.set_active(true)
		elif frame == ATTACK_END_FRAME:
			#$AnimatedSprite2D/Hitbox2/CollisionShape2D.disabled = true
			hitbox.set_active(false)

func attack():
	if is_attacking:
		return
		
	is_attacking = true
	#set_physics_process(false)
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	#set_physics_process(true)
	hitbox.set_active(false)
	is_attacking = false
	animated_sprite_2d.play("idle")
	
func _set_animation():
	if not is_attacking:
		if velocity.x != 0:
			animated_sprite_2d.play("run")
	
			if velocity.x > 0:
				#anim.flip_h = false
				animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x)
			else:
					#anim.flip_h = true
					print('left side!')
					animated_sprite_2d.scale.x = -abs(animated_sprite_2d.scale.x)
		else:
			animated_sprite_2d.play("idle")
