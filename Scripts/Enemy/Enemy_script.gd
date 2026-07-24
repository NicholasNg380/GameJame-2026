extends CharacterBody2D
class_name Enemy

var player: Player

enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL
const ROAM_RADIUS = 300
const ROAM_SPEED = 50

var roam_target: Vector2

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player:
		if global_position.distance_to(player.global_position) < 500:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
	
	match current_state:
		State.PATROL:
			patrol_behaviour()
		State.CHASE:
			print("chase")
			chase_behaviour(_delta)
	
func chase_behaviour(_delta) -> void:
	nav_agent.target_position = player.global_position
	
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	velocity = direction * 100
	move_and_slide()
	look_at(next_position)
	
func patrol_behaviour() -> void:
	if nav_agent.is_navigation_finished():
		print("Picking new target")
		pick_new_roam_target()

	var next_position = nav_agent.get_next_path_position()
	print("Next position: ", next_position)
	var direction = global_position.direction_to(next_position)

	velocity = direction * ROAM_SPEED
	move_and_slide()

	if velocity.length() > 0:
		look_at(next_position)

func pick_new_roam_target():
	var random_direction = Vector2.RIGHT.rotated(randf() * TAU)
	var random_distance = randf_range(50, ROAM_RADIUS)

	roam_target = global_position + random_direction * random_distance
	nav_agent.target_position = roam_target
	
