extends CharacterBody2D

var player: Player

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	print(player)

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
		
	velocity = direction * 300
	move_and_slide()
