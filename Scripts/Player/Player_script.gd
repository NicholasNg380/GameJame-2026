extends CharacterBody2D
class_name Player

@onready var hack_area: Area2D = $HackArea
@onready var camera = $Camera2D
@onready var sword_anim = $Sword
@onready var tank_anim = $Tank
@onready var magnet_anim = $Magnet

const ACCELERATION: int = 15
const FRICTION: int = 0
var MAX_SPEED: float = 500.0
var TYPE: String = ""
var HEALTH: float = 100.0

# Array contains Health then speed
var ROBOTS: Dictionary = {"Sword": [100.0, 500.0], "Tank": [200.0, 250.0], "Magnet": [50.0, 750.0]}


func _ready():
	add_to_group("player")

func _physics_process(delta):
	_movement(delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("hack"):
		hack_robot()

func _movement(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	var lerp_weight = delta * (ACCELERATION if input else 50)
	
	velocity = lerp(velocity, input * (MAX_SPEED), lerp_weight)
	if velocity.length() > 0:
		rotation = atan2(velocity.y, velocity.x)
	

func closest_robot() -> Enemy:
	var overlapping_bodies = hack_area.get_overlapping_bodies()
	
	if overlapping_bodies.is_empty():
		return null
		
	var closest_robot: Enemy = null
	var min_distance: float = INF
	
	for body in overlapping_bodies:
		# Ignore the player itself if it accidentally triggers the area
		if body == self: 
			continue
			
		var dist_sq = global_position.distance_squared_to(body.global_position)
		if dist_sq < min_distance:
			min_distance = dist_sq
			closest_robot = body
	
	return closest_robot

func hack_robot():
	var robot = closest_robot()
	
	if robot == null:
		return
	
	var player_pos = global_position
	var robot_pos = robot.global_position
	
	robot_change(robot.type)
	
	camera.position_smoothing_enabled = true
	
	global_position = robot_pos
	robot.global_position = player_pos
	
	robot.queue_free()
	await get_tree().create_timer(0.3).timeout
	camera.position_smoothing_enabled = false


func robot_change(type) -> void:
	TYPE = type
	HEALTH = ROBOTS[TYPE][0]
	MAX_SPEED = ROBOTS[TYPE][1]
	
	sword_anim.visible = false
	tank_anim.visible = false
	magnet_anim.visible = false
	match type:
		"Sword":
			sword_anim.visible = true
		"Tank":
			tank_anim.visible = true
		"Magnet":
			magnet_anim.visible = true
	
