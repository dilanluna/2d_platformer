extends CharacterBody2D


@export var move_speed: float
@export var jump_speed: float
@export var double_jump_scale: float
@export var wall_slide_gravity_scale: float

@onready var coyote_timer = $CoyoteTimer
@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer

var is_jumping = false
var is_facing_right = true
var has_double_jump = false
var has_leaved_floor = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	update_animations()

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	move_x(direction)
	move_and_slide()
	
	jump(delta)

func flip():
	#If pleyer is facing right and moving left or facing left and moving right
	#Scale root node on x axis for flip player
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right

func update_animations():
	if is_on_wall_only():
		animation_player.play("wall_jump")
		return
	
	#Swap between jump and fall animations
	if not is_on_floor():
		if velocity.y > 0:
			animation_player.play("fall")
		elif velocity.y < 0:
			animation_player.play("jump")
		return
	
	#Swap between run and idle animations
	if velocity.x:
		animation_player.play("run")
	else:
		animation_player.play("idle")
	
	
	#var playback = animation_tree.get("parameters/playback")
	#
	##Swap between jump and fall animations
	#if not is_on_floor_only():
		#if velocity.y > 0:
			#playback.travel("fall")
		#elif velocity.y < 0:
			#playback.travel("jump")
		#return
	#
	##Swap between run and idle animations
	#if velocity.x:
		#playback.travel("run")
	#else:
		#playback.travel("idle")
	
	#if velocity.x:
		#animation_tree.set("parameters/conditions/is_moving", true)
		#animation_tree.set("parameters/conditions/is_idle", false)
	#else:
		#animation_tree.set("parameters/conditions/is_moving", false)
		#animation_tree.set("parameters/conditions/is_idle", true)

func move_x(direction):
	velocity.x = direction * move_speed
	flip()

func can_jump():
	#return is_on_floor() or not coyote_timer.is_stopped()
	if is_on_floor():
		return true
	elif not coyote_timer.is_stopped():
		return true
	else:
		return false

func jump(delta):
	if not is_on_floor():
		if not has_leaved_floor:
			coyote_timer.start()
			has_leaved_floor = true
		
	if is_jumping and is_on_floor():
		is_jumping = false
		has_double_jump = false
		has_leaved_floor = false
	
	if is_jumping and not has_double_jump and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed * double_jump_scale
		has_double_jump = true
	
	if can_jump() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
		is_jumping = true
	
	#Apply gravity to player
	if not is_on_floor():
		if is_on_wall() and velocity.y > 0:
			velocity.y += gravity * wall_slide_gravity_scale * delta
		else:
			velocity.y += gravity * delta              
