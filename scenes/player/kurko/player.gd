extends CharacterBody2D

var is_attacking = false

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

func _physics_process(delta: float) -> void:
	# Если атакуем, не обрабатываем ввод для движения и прыжков
	if is_attacking:
		move_and_slide() # Оставляем гравитацию, если персонаж падает во время удара
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	var anim = $AnimatedSprite2D
	
		
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		anim.play("attack")
		$AnimatedSprite2D/SwordArea/CollisionShape2D.disabled = false
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
			

func _on_attack_finished():
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D/SwordArea/CollisionShape2D.disabled = true
