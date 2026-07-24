extends CharacterBody2D
class_name Enemy

var player: Player
var on: bool = false
var spawning: bool = false
var SPEED: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

enum State {REST, CHASE, ATTACK, COOLDOWN}
var current_state: State = State.REST

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	attack_status(global_position.distance_to(player.global_position))
	match current_state:
		State.REST:
			if global_position.distance_to(player.global_position) < 450 and !on and !spawning:
				spawning = true
				anim.play("Waking up")
		State.CHASE:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * SPEED
			look_at(player.global_position)
			move_and_slide()
		State.ATTACK:
			velocity = Vector2.ZERO
			attack()

func attack() -> void:
	pass

func attack_status(distance: float) -> void:
	if distance <= 70 and current_state != State.COOLDOWN:
		if current_state != State.COOLDOWN:
			current_state = State.ATTACK
