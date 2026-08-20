extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var attack := false
var isDialog = false
var main_player
var main_player_animated_sprite

func _ready() -> void:
	attack = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
	#	velocity.x = direction * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_dialogue_detection_body_entered(body: CharacterBody2D) -> void:
	if not body.is_in_group("main_player"):
		return
	
	main_player = body
	main_player_animated_sprite = body.get_node("AnimatedSprite2D") as AnimatedSprite2D
	
	if not isDialog:
		main_player.is_frozen = true
		#main_player.velocity = Vector2.ZERO
		main_player_animated_sprite.play("idle")
		
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Dialogic.start("timeline")
		Dialogic.timeline_ended.connect(_on_dialogic_end)

func _on_dialogic_end():
	main_player.is_frozen = false
	isDialog = true
	attack = true
	#main_player.velocity = Vector2
	

# если циклоп помер:
#Dialogic.VAR.CiclopusFall = true
