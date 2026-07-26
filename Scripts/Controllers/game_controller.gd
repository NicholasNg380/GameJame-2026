extends Node
class_name GameController

@export var HOST_TIME := 30.0
const DAMAGE_TIME_PENALTY := 1.0

var won: bool = false
var lost: bool = false
var current_robot = null
var time_remaining := 0.0
var update_timer := 0.0
var timer_active := false

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
@onready var minigame = $CanvasLayer/HBoxContainer
@onready var health = $"CanvasLayer/Death Timer"
@onready var countdown = $CanvasLayer/Label
@onready var audio = $"../AudioStreamPlayer2"
@onready var enemies_left = $"CanvasLayer/Remaining"
@onready var score = $"CanvasLayer/Score"
@onready var combo = $"CanvasLayer/Combo"

const MINIGAME_KEY = "res://Scenes/UI/minigame_key.tscn"
const HACK_SOUND = preload("res://Assets/Audio/Hacking_Sound.wav")
const HACK_WIN_SOUND = preload("res://Assets/Audio/win_hack.wav")
const HACK_FAIL_SOUND = preload("res://Assets/Audio/fail_hack.wav")
const MAP_SCENE = "res://Scenes/UI/Map/Map.tscn"

func _ready():
	add_to_group("game_controller")
	minigame_init_msg.visible = false
	host_timer.timeout.connect(_on_host_timer_finished)
	time_remaining = HOST_TIME
	Score.score_changed.connect(update_score)
	Score.combo_changed.connect(update_combo)
	
	update_score(Score.score)
	update_combo(Score.combo)

# -------------------------
# WIN SYSTEM
# -------------------------
func world_to_ui_position(world_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_position
	
func check_win():
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		won = true
		print("You Win!")
		get_tree().change_scene_to_file(MAP_SCENE)

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
	print("Enemies remaining: ", get_tree().get_nodes_in_group("enemies").size())
	#Update health bar
	countdown.text = str(int(ceil(time_remaining)))
	enemies_left.text = ("Enemies Remaining: " + str(get_tree().get_nodes_in_group("enemies").size()))
	if timer_active and time_remaining > 0:
		time_remaining -= delta
		update_timer += delta
	
		if update_timer >= 0.5:
			update_timer = 0.0
			health.value = 100 * (time_remaining / HOST_TIME)

		if time_remaining <= 0.0:
			time_remaining = 0.0
			_on_time_up()
	
	if is_hacking:
		#audio.volume_db = -20
		#audio.pitch_scale = 0.7
		if hackListPointer == HACK_DIFFICULTY + hack_modifier:
			time_remaining = HOST_TIME
			update_timer = 0.5
			
			if !timer_active:
				timer_active = true
				print("Virus timer started")
			
			hackSuccess.emit(robot_being_hacked)
			audio.stream = HACK_WIN_SOUND
			audio.play()
			
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
	else:
		pass
		#audio.volume_db = -15
		#audio.pitch_scale = 1
	

func successfulInput(input, required):
	if required == input:
		hackListReferences[hackListPointer].texture.region.position.x += 9
		audio.pitch_scale = randf_range(0.95, 1.05)
		hackListPointer += 1
		audio.stream = HACK_SOUND
		audio.play()
	else:
		hackFail.emit()
		audio.stream = HACK_FAIL_SOUND
		audio.play()
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
	minigame.global_position = world_to_ui_position(robot.global_position) + Vector2(0, -60)
	for i in range(HACK_DIFFICULTY + hack_modifier):
		var rand = rng.randi_range(0, 3)
		
		var key_scene = load(MINIGAME_KEY)
		var key = key_scene.instantiate()
		key.texture = key.texture.duplicate()
		key.texture.region.position.x = 18*rand
		minigame.add_child(key)
		hackList.append(rand)
		hackListReferences.append(key)
	
func _on_player_damaged(_amount: float) -> void:
	if timer_active:
		time_remaining = max(0.0, time_remaining - DAMAGE_TIME_PENALTY)
		health.value = 100 * (time_remaining / HOST_TIME)
		if time_remaining <= 0.0:
			_on_time_up()

func _on_time_up() -> void:
	if lost:
		return
	lost = true
	timer_active = false
	print("Time's up — Game Over")
	# TODO: actual game-over flow (freeze player, show a screen, reload level, etc.)
	get_tree().paused = true

func _on_died():
	await get_tree().create_timer(0.5).timeout # wait a sec
	check_win()
	
func number_of_enemies() -> int:
	return get_tree().get_nodes_in_group("enemies").size()
	
func update_score(value):
	score.text = "Score: " + str(value)

func update_combo(value):
	combo.text = "Combo: %.1fx" % value
