extends CharacterBody2D

@onready var player = get_node("../../Player/Player")
@onready var anim = get_node("AnimationPlayer")
@onready var raycast_right = get_node("raycast_right")
@onready var raycast_left = get_node("raycast_left")

var chase = false
const SPEED = 50
var facing_direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if chase:
		print("achei")
		var direction = player.global_position.x - self.global_position.x
		
		if direction > 0:
			get_node("AnimatedSprite2D").flip_h = false
			velocity.x = SPEED
			facing_direction = 1
		else :
			get_node("AnimatedSprite2D").flip_h = true
			velocity.x = -SPEED
			facing_direction = - 1
				
	else: # n to perseguindo
		
		if !raycast_right.is_colliding() and is_on_floor():
			get_node("AnimatedSprite2D").flip_h = true
			facing_direction = facing_direction * - 1
			
		if !raycast_left.is_colliding() and is_on_floor():
			get_node("AnimatedSprite2D").flip_h = false
			facing_direction = facing_direction * - 1
		
		if facing_direction == - 1:
			velocity.x = SPEED * facing_direction
		else:
			velocity.x = SPEED * facing_direction			
		#velocity.x = 0.0
		
	move_and_slide()
	movements()

func movements():
	if velocity.x:
		anim.play("Run")
	else:
		anim.play("Idle")
	
		
func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true


func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false
