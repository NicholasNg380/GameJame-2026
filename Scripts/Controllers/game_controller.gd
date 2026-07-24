extends Node
class_name GameController

const HOST_TIME := 10.0

var won: bool = false
var current_robot = null
var time_remaining := 0.0
var update_timer := 0.0

const TIME_SLOW = 0.1

const HACK_DIFFICULTY = 4
var hack_modifier = 0
var is_hacking = false

signal hackFail
signal hackSuccess(robot)

var hackList
var hackListReferences
var hackListPointer = 0
var robot_being_hacked


@onready var minigame_init_msg = $Sprite2D
@onready var host_timer: Timer = $HostTimer
@onready var minigame = $HBoxContainer
@onready var health = $"CanvasLayer/Death Timer"

const MINIGAME_KEY = "res://Scenes/UI/minigame_key.tscn"

func _ready():
	minigame_init_msg.visible = false
	host_timer.timeout.connect(_on_host_timer_finished)
	time_remaining = HOST_TIME

# -------------------------
# WIN SYSTEM
# -------------------------

func check_win():
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		won = true
		print("You Win!")

# -------------------------
# HOST TIMER SYSTEM
# -------------------------

func start_host(robot):
	current_robot = robot
	host_timer.start(HOST_TIME)
	print("New host acquired")


func _on_host_timer_finished():
	print("Firewall breached!")
	if current_robot:
		current_robot.destroy()
		current_robot = null


func _process(delta):
	#Update health bar
	if time_remaining > 0:
		time_remaining -= delta
		update_timer += delta
		if update_timer >= 0.5:
			update_timer = 0.0
			health.value = 100 * (1-((HOST_TIME-time_remaining)/HOST_TIME))
			
	if is_hacking:
		if hackListPointer == HACK_DIFFICULTY + hack_modifier:
			time_remaining = HOST_TIME
			update_timer = 0.5
			hackSuccess.emit(robot_being_hacked)
			
			is_hacking=false
			minigame.visible = false
			Engine.time_scale = 1
		if Input.is_action_just_pressed("up"):
			successfulInput(0, hackList[hackListPointer])
		elif Input.is_action_just_pressed("left"):
			successfulInput(1, hackList[hackListPointer])
		elif Input.is_action_just_pressed("down"):
			successfulInput(2, hackList[hackListPointer])
		elif Input.is_action_just_pressed("right"):
			successfulInput(3, hackList[hackListPointer])
	if !host_timer.is_stopped():
		time_remaining = host_timer.time_left
		print(time_remaining)
	

func successfulInput(input, required):
	if required == input:
		hackListReferences[hackListPointer].texture.region.position.x += 9
		hackListPointer += 1
	else:
		hackFail.emit()
		Engine.time_scale = 1
		is_hacking = false
		minigame.visible = false

# -------------------------
# HACKING TIMER SYSTEM
# -------------------------

func _on_player_can_hack(robot: Variant) -> void:
	if not is_hacking:
		minigame_init_msg.visible = true
		minigame_init_msg.z_index = 100
		minigame_init_msg.global_position = robot.global_position + Vector2(0, -60)


func _on_player_cannot_hack() -> void:
	minigame_init_msg.visible = false


func _on_player_hacking(robot) -> void:
	#Makes it look like it was pressed
	minigame.visible = true
	Engine.time_scale = TIME_SLOW
	robot_being_hacked = robot
	is_hacking = true
	minigame_init_msg.visible = false
	for n in minigame.get_children():
		n.queue_free()
	var rng = RandomNumberGenerator.new()
	hackList = []
	hackListReferences = []
	hackListPointer = 0
	minigame.global_position = robot.global_position + Vector2(0, -60)
	for i in range(HACK_DIFFICULTY + hack_modifier):
		var rand = rng.randi_range(0, 3)
		
		var key_scene = load(MINIGAME_KEY)
		var key = key_scene.instantiate()
		key.texture = key.texture.duplicate()
		key.texture.region.position.x = 18*rand
		minigame.add_child(key)
		hackList.append(rand)
		hackListReferences.append(key)
	
	
	
	
