extends CharacterBody2D
class_name Player

@onready var hack_area: Area2D = $HackArea
@onready var camera = $Camera2D
@onready var sword_anim = $Sword
@onready var tank_anim = $Tank
@onready var magnet_anim = $Magnet
@onready var terminal_anim = $Terminal
@onready var minigame = $Node2D/Minigame
@onready var sword_hurtbox = $Sword_Hurtbox/CollisionShape2D
@onready var tank_hurtbox = $Tank_Hurtbox/CollisionShape2D
@onready var grapple = $GrappleHook
@onready var raycast = $RayCast2D


var gameStart = false

var isHacking = false

signal hacking(robot)
signal canHack(robot)
signal cannotHack

const ACCELERATION: int = 15
const FRICTION: int = 0
var MAX_SPEED: float = 500.0
var TYPE: String = ""
var HEALTH: float = 100.0
var ANIM_PLAYER: AnimatedSprite2D = terminal_anim;

var combo1Timer: float = 0;
var COMBO_LEEWAY: float = 0.6;
var combo2Timer: float = 0;

var grapple_speed = 1500
var grapple_distance: float = 500.0
var is_grappling = false
var grapple_target_global: Vector2

var hackFail = true

# Array contains Health then speed
var ROBOTS: Dictionary = {"Sword": [100.0, 500.0], "Tank": [200.0, 250.0], "Magnet": [50.0, 750.0]}

func _ready():
	ANIM_PLAYER = terminal_anim
	

func _physics_process(delta):
	print(is_grappling)
	if !gameStart:
		closest_robot()
		if Input.is_action_just_pressed("hack"):
			hack_robot()
		if !hackFail:
				add_to_group("player")
				gameStart = true
		return
	
	_movement(delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("hack"):
		hack_robot()
	
	if Input.is_action_just_pressed("attack"):
		match TYPE:
			"Sword":
				do_sword_attack();
			"Tank":
				do_tank_attack();
			"Magnet":
				do_magnet_attack();
	if Input.is_action_just_pressed("special"):
		match TYPE:
			"Sword":
				do_sword_special();
			"Tank":
				if !is_grappling:
					do_tank_special();
			"Magnet":
				do_magnet_special();
	if combo1Timer > 0 or combo2Timer > 0:
		combo1Timer -= delta
		combo2Timer -= delta
	closest_robot()
	
	if is_grappling:
		var start = global_position + Vector2(45, -33).rotated(rotation)
		grapple.set_point_position(0, grapple.to_local(start))
		grapple.set_point_position(1, grapple.to_local(grapple_target_global))

func _movement(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	if !isHacking and !is_grappling:
		var lerp_weight = delta * (ACCELERATION if input else 50)
		
		velocity = lerp(velocity, input * (MAX_SPEED), lerp_weight)
		if velocity.length() > 0:
			if TYPE != "Magnet":
				rotation = atan2(velocity.y, velocity.x)
	
	if ANIM_PLAYER != null and not ANIM_PLAYER.is_playing(): #and  ANIM_PLAYER.animation != "Grapple":
		
		ANIM_PLAYER.play("Walking")
		
func closest_robot() -> Enemy:
	var overlapping_bodies = hack_area.get_overlapping_bodies()
	
	if overlapping_bodies.is_empty():
		cannotHack.emit()
		return null
		
	var closest_robot: Enemy = null
	var min_distance: float = INF
	
	for body in overlapping_bodies:
		# Ignore the player itself if it accidentally triggers the area
		if body == self or !body.canBeHacked(): 
			continue
			
		var dist_sq = global_position.distance_squared_to(body.global_position)
		if dist_sq < min_distance:
			min_distance = dist_sq
			closest_robot = body
	if closest_robot != null:
		canHack.emit(closest_robot)
	else:
		cannotHack.emit()
	return closest_robot
	

func hack_robot():
	
	var robot = closest_robot()
	
	if robot == null:
		return
	velocity = Vector2(0, 0)
	isHacking = true
	hacking.emit(robot)

func _on_game_controller_hack_success(robot) -> void:
	if robot:
		var player_pos = global_position
		var robot_pos = robot.global_position
		hackFail = false
		
		robot_change(robot.type)

		camera.position_smoothing_enabled = true
		
		global_position = robot_pos
		robot.global_position = player_pos
		
		robot.queue_free()
		await get_tree().create_timer(0.3).timeout
		camera.position_smoothing_enabled = false
		
		isHacking = false
	else:
		_on_game_controller_hack_fail()
		
	
func _on_game_controller_hack_fail() -> void:
	isHacking = false
	hackFail = true
	
func robot_change(type) -> void:
	TYPE = type
	HEALTH = ROBOTS[TYPE][0]
	MAX_SPEED = ROBOTS[TYPE][1]
	
	sword_anim.visible = false
	tank_anim.visible = false
	magnet_anim.visible = false
	terminal_anim.visible = false
	match type:
		"Sword":
			sword_anim.visible = true
			ANIM_PLAYER = sword_anim
		"Tank":
			tank_anim.visible = true
			ANIM_PLAYER = tank_anim
		"Magnet":
			magnet_anim.visible = true
			rotation = 0;
			ANIM_PLAYER = magnet_anim
	
func do_sword_attack():
	if combo2Timer > 0:
		ANIM_PLAYER.play("Combo Slash")
		combo2Timer = 0;
	elif combo1Timer > 0:
		ANIM_PLAYER.play("Right Slash")
		combo2Timer = COMBO_LEEWAY
		combo1Timer = 0;
	else:
		ANIM_PLAYER.play("Left Slash")
		combo1Timer = COMBO_LEEWAY;
	sword_hurtbox.disabled = false
	await get_tree().create_timer(0.1).timeout
	sword_hurtbox.disabled = true

func do_sword_special():
	ANIM_PLAYER.play("Parry")

func do_tank_attack():
	ANIM_PLAYER.play("Shield Bash")
	tank_hurtbox.disabled = false
	await get_tree().create_timer(0.1).timeout
	tank_hurtbox.disabled = true

func do_tank_special():	
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		velocity = Vector2.ZERO
		ANIM_PLAYER.play("Grapple")
		is_grappling = true
		ANIM_PLAYER.speed_scale = 1 
		
		grapple.visible = true
		grapple_target_global = raycast.get_collision_point()
		await animate_grapple(grapple_target_global)
		await move_to_grapple(grapple_target_global)
		
		grapple.visible = false
		is_grappling = false
		ANIM_PLAYER.pause()
		ANIM_PLAYER.frame = ANIM_PLAYER.sprite_frames.get_frame_count("Grapple") - 1

func animate_grapple(target):
	grapple.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	grapple.texture_mode = Line2D.LINE_TEXTURE_TILE
	var start = global_position + Vector2(45, -33).rotated(rotation)
	var local_target = grapple.to_local(target)


	
	grapple.clear_points()
	grapple.add_point(grapple.to_local(start))
	grapple.add_point(grapple.to_local(start))

	var distance = start.distance_to(target)
	var time = distance / grapple_speed

	var tween = create_tween()
	tween.tween_method(
		func(pos): grapple.set_point_position(1, pos),
		grapple.to_local(start),
		local_target,
		time
	)

	await tween.finished

func move_to_grapple(target):
	var distance = global_position.distance_to(target)
	var time = distance / grapple_speed

	var tween = create_tween()
	tween.tween_property(
		self,
		"global_position",
		target,
		time
	)

	await tween.finished

func do_magnet_attack():
	ANIM_PLAYER.play("Spit")

func do_magnet_special():
	pass

func _on_terminal_animation_finished() -> void:
	if ANIM_PLAYER.animation == "Boot":
		ANIM_PLAYER.play("Loop")
