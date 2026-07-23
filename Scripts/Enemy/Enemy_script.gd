extends CharacterBody2D
class_name Enemy

var player: Player

func _ready():
	add_to_group("enemies")
	print("test")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
		
	velocity = direction * 100
	move_and_slide()
	look_at(player.global_position)
