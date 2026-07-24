extends CharacterBody2D
class_name Enemy

var player: Player
var on: bool = false
var spawning: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

"""enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL
const ROAM_RADIUS = 300
const ROAM_SPEED = 50

var direction: Vector2 = Vector2.ZERO

var roam_target: Vector2
var roam_timer: float"""

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
		
	if global_position.distance_to(player.global_position) < 450 and !on and !spawning:
		spawning = true
		anim.play("Waking up")
	
	if on:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 400
		move_and_slide()
		
	
"""func patrol_behaviour(_delta) -> void:
	roam_timer -= _delta
	if global_position.distance_to(roam_target) < 8 or nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if roam_timer <= 0:
			pick_new_roam_target()
		return
	print(nav_agent.is_navigation_finished())
	set_new_roam_target(100)

func pick_new_roam_target() -> void:
	var angle = randf_range(0, TAU)
	var distance = randf_range(20, 200)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	
	roam_target = self.global_position + offset
	nav_agent.target_position = roam_target
	roam_timer = randf_range(1.0, 3.0)
	
func set_new_roam_target(speed) -> void:
	var next_pos = nav_agent.get_next_path_position()
	direction = (next_pos - global_position).normalized()
	velocity = direction * speed
	nav_agent.set_velocity(velocity)"""
	
	
