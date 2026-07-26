extends CharacterBody2D
class_name Player

@onready var hack_area: Area2D = $HackArea
@onready var camera = $Camera2D
@onready var sword_anim = $Sword
@onready var tank_anim = $Tank
@onready var magnet_anim = $Magnet
@onready var terminal_anim = $Terminal
#@onready var minigame = $Node2D/Minigame
@onready var sword_hurtbox = $Sword_Hurtbox/CollisionShape2D
@onready var tank_hurtbox = $Tank_Hurtbox/CollisionShape2D
@onready var grapple = $GrappleHook
@onready var raycast = $RayCast2D
@export var knockback_strength: float = 4.0

@onready var special_prog_bar = $TextureProgressBar
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false
var is_invulnerable := false




var robots = {"Sword": preload("res://Scenes/Objects/Sword_enemy.tscn"), "Magnet": preload("res://Scenes/Objects/Magnet_enemy.tscn"), 
"Tank": preload("res://Scenes/Objects/Tank_enemy.tscn")}

const MAGNET_BOMB = preload("res://Scenes/Objects/magnet_bomb.tscn")
@export var max_magnets := 3
var current_magnets = 0
var magnet_list = []

var gameStart = false

var isHacking = false

var player_direction

signal hacking(robot)
signal canHack(robot)
signal cannotHack
signal damaged(amount)

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

var dash_speed: int = 10
var is_dashing
var special_on_cooldown := false
const SPECIAL_COOLDOWN := 1.0
var current_special_cooldown: float = 0.0

var scrap = 0

const SHOCKWAVE_RADIUS := 250.0
const SHOCKWAVE_FORCE := 700.0


var hackFail = true

var sword_hurtbox_users := 0

# Array contains Health then speed
var ROBOTS: Dictionary = {"Sword": [100.0, 500.0], "Tank": [200.0, 250.0], "Magnet": [50.0, 750.0]}

func _ready():
	ANIM_PLAYER = terminal_anim
	
func _process(delta):
	if special_on_cooldown:
		#special_prog_bar.rotation = -rotatio
		special_prog_bar.visible = true
		special_prog_bar.value = 100 * ((SPECIAL_COOLDOWN - current_special_cooldown)/SPECIAL_COOLDOWN)
	else:
		special_prog_bar.visible = false
	if current_special_cooldown <= 0:
		current_special_cooldown = 0
		special_on_cooldown = false
	else:
		special_on_cooldown = true
		current_special_cooldown -= delta
func _physics_process(delta):
	if !gameStart:
		closest_robot()
		if Input.is_action_just_pressed("hack"):
			hack_robot()
		if !hackFail:
				add_to_group("player")
				gameStart = true
		return
	
	_movement(delta)
	if knockback_velocity.length() >= 10:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1500.0 * delta)
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
	player_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	if !isHacking and !is_grappling and !is_dashing and !is_knocked_back:
		var lerp_weight = delta * (ACCELERATION if player_direction else 50)
		
		velocity = lerp(velocity, player_direction * (MAX_SPEED), lerp_weight)
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
		
	var closest: Enemy = null
	var min_distance: float = INF
	
	for body in overlapping_bodies:
		print("Yelo")
		# Ignore the player itself if it accidentally triggers the area
		if body == self or !body.canBeHacked(): 
			continue
		var dist_sq = global_position.distance_squared_to(body.global_position)
		if dist_sq < min_distance:
			min_distance = dist_sq
			closest = body
	if closest != null:
		canHack.emit(closest)
	else:
		cannotHack.emit()
	return closest
	

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
		if TYPE != "":
			var death_anim = robots[TYPE].instantiate()
			death_anim.global_position = player_pos
			death_anim.rotation = rotation
			get_tree().current_scene.add_child(death_anim)
			
			death_anim.die()
		robot_change(robot.type)

		camera.position_smoothing_enabled = true
		
		global_position = robot_pos
		robot.queue_free()
		
		robot.die()
		trigger_shockwave(robot_pos)
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
	ANIM_PLAYER.play("Waking up")
	
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
	_enable_sword_hurtbox()
	await get_tree().create_timer(0.1).timeout
	_disable_sword_hurtbox()

func do_sword_special():
	if special_on_cooldown:
		return
	special_on_cooldown = true

	ANIM_PLAYER.play("Dash")
	velocity *= dash_speed
	is_dashing = true

	_enable_sword_hurtbox()
	await get_tree().create_timer(0.1).timeout
	_disable_sword_hurtbox()
	is_dashing = false
	
	current_special_cooldown = SPECIAL_COOLDOWN - 0.1
	await get_tree().create_timer(SPECIAL_COOLDOWN - 0.1).timeout
	special_on_cooldown = false

func do_tank_attack():
	ANIM_PLAYER.play("Shield Bash")
	tank_hurtbox.disabled = false
	await get_tree().create_timer(0.1).timeout
	tank_hurtbox.disabled = true

func do_tank_special():	
	if special_on_cooldown:
		return
	special_on_cooldown = true
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var target_body = raycast.get_collider()
		var hit_enemy = target_body if target_body is CharacterBody2D and target_body.is_in_group("enemies") else null

		velocity = Vector2.ZERO
		ANIM_PLAYER.play("Grapple")
		is_grappling = true
		is_invulnerable = true
		ANIM_PLAYER.speed_scale = 1

		grapple.visible = true
		grapple_target_global = raycast.get_collision_point()
		await animate_grapple(grapple_target_global)
		await move_to_grapple(grapple_target_global)

		if hit_enemy and is_instance_valid(hit_enemy):
			tank_hurtbox.disabled = false
			await get_tree().create_timer(0.1).timeout
			tank_hurtbox.disabled = true

		grapple.visible = false
		is_grappling = false
		is_invulnerable = false
		ANIM_PLAYER.pause()
		ANIM_PLAYER.frame = ANIM_PLAYER.sprite_frames.get_frame_count("Grapple") - 1
	
	current_special_cooldown = SPECIAL_COOLDOWN
	await get_tree().create_timer(SPECIAL_COOLDOWN).timeout
	special_on_cooldown = false

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
	if current_magnets < max_magnets:
		current_magnets += 1
		ANIM_PLAYER.play("Spit")
		var obj = MAGNET_BOMB.instantiate()
		obj.global_position = position
		get_tree().current_scene.add_child(obj)
		obj.launch(position, player_direction)
		magnet_list.append(obj)

func do_magnet_special():
	for i in magnet_list:
		i.activate()
		
		magnet_list.erase(i)
	current_magnets = 0

func _on_terminal_animation_finished() -> void:
	if ANIM_PLAYER.animation == "Boot":
		ANIM_PLAYER.play("Loop")

func take_damage(amount: float, source_position: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable:
		return
	elif TYPE == "Sword":
		sword_anim.play("Hit")
	elif TYPE == "Tank":
		tank_anim.play("Hit")
	elif TYPE == "Magnet":
		magnet_anim.play("Hit")
	
	var direction = global_position.direction_to(source_position)
	knockback_velocity = -direction * (MAX_SPEED / knockback_strength)
	is_knocked_back = true
	is_invulnerable = true
	await get_tree().create_timer(0.3).timeout
	is_knocked_back = false
	is_invulnerable = false
	HEALTH -= amount
	damaged.emit(amount)

func trigger_shockwave(origin: Vector2) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.isKnocked():
			var dist = origin.distance_to(enemy.global_position)
			if dist <= SHOCKWAVE_RADIUS:
				enemy.apply_knockback(origin, SHOCKWAVE_FORCE)

func _enable_sword_hurtbox() -> void:
	sword_hurtbox_users += 1
	sword_hurtbox.disabled = false

func _disable_sword_hurtbox() -> void:
	sword_hurtbox_users -= 1
	if sword_hurtbox_users <= 0:
		sword_hurtbox_users = 0
		sword_hurtbox.disabled = true
