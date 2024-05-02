extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const DASH = 2500

@onready var anim = get_node("AnimationPlayer") # acessa as sprites
@onready var attack_timer = get_node("attack_timer")
@onready var dash_timer = get_node("dash_timer")

var double_jump = 2
var is_attacking = false
var is_crouching = false
var is_dashing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if is_on_floor():
		double_jump = 2
		
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if double_jump > 0:
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				double_jump -= 1
			else:
				velocity.y = JUMP_VELOCITY
				double_jump -= 1	

	if Input.is_action_just_pressed("attack") and check_timers():
		is_attacking = true	
		
	if Input.is_action_just_pressed("Dash") and check_timers():
		is_dashing = true	
		
	if Input.is_action_pressed("crouch") and is_on_floor():
		is_crouching = true	
	if Input.is_action_just_released("crouch"):
		is_crouching = false	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false	
	
	velocity.x = SPEED * direction
	
	if check_timers():
		if is_attacking:
			attack_timer.start() # se eu ataquei, começa o timer
		elif is_dashing:
			dash_timer.start()
			velocity.x = DASH * direction
		movements()
	
	move_and_slide()
	
func movements():
	#se ta andando
	if velocity.x:
		if not velocity.y:
			if is_attacking:
				anim.play("attack")
			elif is_dashing:
				anim.play("Dash")
			else:
				anim.play("run")
		else:
			if is_dashing:
				anim.play("Dash")
			
	else: #to parado
		
		if is_attacking == true:
			anim.play("attack")
		elif is_crouching == true:
			anim.play("crouch")	
		else:		
			anim.play("idle")		
	
	if velocity.y > 0 and check_timers():
		if is_attacking:
			anim.play("attack")
		elif is_dashing:
			anim.play("Dash")	
		else:
			anim.play("fall")
		
	elif velocity.y < 0 and check_timers():
		if is_attacking:
			anim.play("attack")
		elif is_dashing:
			anim.play("Dash")
		else:
			anim.play("jump")				

func check_timers():
	if not attack_timer.is_stopped(): #se o timer ta ligado, nao pode fazer nada
		return false
	if not dash_timer.is_stopped():
		return false
	return true
					
func _on_attack_timer_timeout():
	is_attacking = false
	attack_timer.stop() #parei de atacar, para o timer

func _on_dash_timer_timeout():
	is_dashing = false 
	dash_timer.stop()
