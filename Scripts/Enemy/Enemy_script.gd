extends CharacterBody2D
class_name Enemy

var player: Player
var on: bool = false
var spawning: bool = false
var SPEED: float = 0.0
var type: String
var health: int
var knocked: bool = false
var can_be_hacked: bool = true
@export var knockback_force: float = 400.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $"Damaging Hitbox"

signal died

enum State {REST, CHASE, ATTACK, HIT, COOLDOWN, KNOCKED}
var current_state: State = State.REST

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if health <= 0 and !knocked:
		print("GFD")
		can_be_hacked = true
		health -= 1
		knocked = true
		current_state = State.KNOCKED
		anim.play("Knocked")


func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	attack_status(global_position.distance_to(player.global_position))
	match current_state:
		State.REST:
			if global_position.distance_to(player.global_position) < 450 and !on and !spawning:
				spawning = true
				can_be_hacked = false
				anim.play("Waking up")
		State.CHASE:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * SPEED
			if type != "Magnet":
				look_at(player.global_position)
		State.ATTACK:
			velocity = Vector2.ZERO
			attack()
		State.HIT:
			pass
		State.KNOCKED:
			velocity = Vector2.ZERO
	move_and_slide()

func isKnocked():
	return knocked

func canBeHacked():
	return can_be_hacked

func attack() -> void:
	pass

func attack_status(distance: float) -> void:
	if distance <= 70 and current_state == State.CHASE and type != "Magnet":
		current_state = State.ATTACK

func take_a_lot_of_damage_magnet():
	#anim.play("Hit")
	health -= 1000

func die():
	health = -10
	knocked=true
	current_state = State.KNOCKED
	can_be_hacked = false
	anim.play("Death")
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if game_controller:
		died.connect(game_controller._on_died)

func _on_damaging_hitbox_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if !knocked:
		print(health)
		current_state = State.HIT
		anim.play("Hit")
		var direction = global_position.direction_to(player.global_position)
		velocity = -direction * knockback_force
		if player.TYPE == "Sword":
			health -= 1
		elif player.TYPE == "Tank":
			health -= 2
	elif knocked and can_be_hacked:
		die()

func apply_knockback(source_position: Vector2, force: float) -> void:
	if knocked:
		return
	current_state = State.HIT
	anim.play("Hit")
	var direction = global_position.direction_to(source_position)
	velocity = -direction * force
