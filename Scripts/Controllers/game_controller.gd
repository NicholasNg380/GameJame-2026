extends Node
class_name GameController

const HOST_TIME := 30.0

var won: bool = false
var current_robot = null
var time_remaining := 0.0

@onready var host_timer: Timer = $HostTimer

func _ready():
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
