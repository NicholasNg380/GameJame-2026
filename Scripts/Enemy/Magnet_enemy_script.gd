extends Enemy

var wander_direction := Vector2.ZERO
var wander_timer := 0.0

var attack_timer := 0.0
var ATTACK_TIME := 4.0
const MAGNET_BOMB = preload("res://Scenes/Objects/enemy_magnet_bomb.tscn")

func _ready():
	
	super()
	attack_timer = ATTACK_TIME
	SPEED = 550
	type = "Magnet"
	health = 3

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		can_be_hacked = false
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	elif anim.animation == "Spit":
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.5).timeout # 1-second attack delay
		anim.play("Walking")
		current_state = State.CHASE
	elif anim.animation == "Hit":
		anim.play("Walking")
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.1).timeout # 1-second attack delay
		current_state = State.CHASE
	elif anim.animation == "Death":
		
		self.queue_free()
	elif anim.animation == "Knocked":
		# flash red or something
		#CODE HERE
		await get_tree().create_timer(2).timeout 
		can_be_hacked = false
		anim.play("Death")

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	attack_status(global_position.distance_to(player.global_position))
	
	if attack_timer <= 0:
		attack_timer = ATTACK_TIME
		var obj = MAGNET_BOMB.instantiate()
		obj.global_position = position
		get_tree().current_scene.add_child(obj)
		obj.launch(global_position, global_position.direction_to(player.global_position))

	match current_state:
		State.REST:
			if global_position.distance_to(player.global_position) < 450 and !on and !spawning:
				spawning = true
				can_be_hacked = false
				anim.play("Waking up")
		State.CHASE:
			var away_direction = player.global_position.direction_to(global_position)

			if wander_timer <= 0:
				wander_timer = randf_range(0.5, 1.0)
				wander_direction = Vector2(
					randf_range(-1, 1),
					randf_range(-1, 1)
				).normalized()
			if global_position.distance_to(player.global_position) < 600:
				away_direction = Vector2.ZERO
			var movement_direction = (wander_direction * 0.5).normalized()

			velocity = movement_direction * SPEED 
		State.ATTACK:
			velocity = Vector2.ZERO
			attack()
		State.HIT:
			pass
		State.KNOCKED:
			velocity = Vector2.ZERO
	move_and_slide()
	wander_timer -= _delta
	if (current_state != State.REST):
		attack_timer -= _delta
		
func attack():
	anim.play("Spit")
