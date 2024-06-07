extends CharacterBody2D


@export var move_speed: float
@export var jump_speed: float
@export var wall_slide_gravity_scale: float


@onready var coyote_timer = $CoyoteTimer
@onready var ground_checks = [
	$GroundCheck/LeftRayCast,
	$GroundCheck/MidRayCast,
	$GroundCheck/RightRayCast
]
@onready var wall_checks = [
	$WallCheck/TopRayCast,
	$GroundCheck/MidRayCast,
	$WallCheck/BottomRayCast
]


var is_facing_right = true
var has_leaved_floor = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# First of all apply gravity to the player in order to `is_on_floor` and `is_on_wall`
	# propertly register collitions after `move_and_slide` call
	apply_gravity(delta)
	
	move(Input.get_axis("move_left", "move_right"))
	
	jump()
	
	move_and_slide()


# Is on floor if at least one raycast is intersecting ground
func _is_on_floor():
	for check in ground_checks:
		if check.is_colliding():
			return true
	return false


# Is on wall if most of raycasts are intersecting a wall
func _is_on_wall():
	var collition_count = 0
	for check in wall_checks:
		if check.is_colliding():
			collition_count += 1
	return collition_count > (len(wall_checks) / 2)


func flip():
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		scale.x *= -1
		is_facing_right = not is_facing_right


func move(direction):
	velocity.x = direction * move_speed
	flip()


func is_on_air():
	return not _is_on_floor() and not _is_on_wall()


func is_falling():
	return velocity.y > 0

func is_going_up():
	return velocity.y < 0

func can_jump():
	return _is_on_floor() or (not coyote_timer.is_stopped() and is_falling())


func jump():
	if _is_on_floor():
		has_leaved_floor = false
	
	# Start coyote timer
	if not _is_on_floor() and not has_leaved_floor:
			coyote_timer.start()
			has_leaved_floor = true
	
	# Wall jump
	#if Input.is_action_just_pressed("jump") and _is_on_wall():
		#velocity.y += -500
		#velocity.x += -1200 * scale.x
	
	# Jump cancel
	if Input.is_action_just_released("jump") and not _is_on_wall() and is_going_up():
		velocity.y = 0
	
	# Normal jump
	if Input.is_action_just_pressed("jump") and can_jump():
		velocity.y = -jump_speed


func apply_gravity(delta):
	var applied_gravity = gravity
	if _is_on_wall() and velocity.y > 0:
		applied_gravity *= wall_slide_gravity_scale
	
	velocity.y += applied_gravity * delta
