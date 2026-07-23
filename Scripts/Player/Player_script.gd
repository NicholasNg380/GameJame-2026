extends CharacterBody2D
class_name Player

const ACCELERATION: int = 15
const FRICTION: int = 0
var MAX_SPEED: float = 500.0

func _ready():
	add_to_group("player")

func _physics_process(delta):
	_movement(delta)
	move_and_slide()

func _movement(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	var lerp_weight = delta * (ACCELERATION if input else 50)
	
	velocity = lerp(velocity, input * (MAX_SPEED), lerp_weight)
