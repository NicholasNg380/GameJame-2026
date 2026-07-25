extends CharacterBody2D
class_name Enemy

var player: Player
var on: bool = false
var spawning: bool = false
var SPEED: float = 0.0
var type: String

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var damaging_hitbox = $"Damaging Hitbox"


enum State {REST, CHASE, ATTACK, HIT, COOLDOWN}
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
			if type != "Magnet":
				look_at(player.global_position)
			move_and_slide()
		State.ATTACK:
			velocity = Vector2.ZERO
			attack()
		State.HIT:
			anim.play("Hit")
			var direction = global_position.direction_to(player.global_position)
			velocity = -1 * direction * 10

func attack() -> void:
	pass

func attack_status(distance: float) -> void:
	if distance <= 70 and current_state != State.COOLDOWN:
		current_state = State.ATTACK
