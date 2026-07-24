extends Node
class_name GameController

const HOST_TIME := 30.0

var won: bool = false
var current_robot = null
var time_remaining := 0.0
const HACK_DIFFICULTY = 4
var hack_modifier = 0
var is_hacking = false

signal hackFail
signal hackSuccess

@onready var minigame_init_msg = $Sprite2D
@onready var host_timer: Timer = $HostTimer
@onready var minigame = $HBoxContainer

const MINIGAME_KEY = "res://Scenes/UI/minigame_key.tscn"

func _ready():
	minigame_init_msg.visible = false
	host_timer.timeout.connect(_on_host_timer_finished)

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
	if !host_timer.is_stopped():
		time_remaining = host_timer.time_left
		print(time_remaining)


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
	is_hacking = true
	minigame_init_msg.visible = false
	for n in minigame.get_children():
		n.queue_free()
	var rng = RandomNumberGenerator.new()
	var hackList: Array = []
	minigame.global_position = robot.global_position + Vector2(0, -60)
	for i in range(HACK_DIFFICULTY + hack_modifier):
		var rand = rng.randi_range(0, 3)
		print(rand)
		var key_scene = load(MINIGAME_KEY)
		var key = key_scene.instantiate()
		key.texture.region.position.x = 18*rand
		minigame.add_child(key)
		hackList.append(key)
	
	
	
	
