extends "Enemy_script.gd"

@onready var attack_hitbox = $Attack_Hitbox/CollisionShape2D
var is_attacking := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SPEED = 225
	type = "Tank"
	health = 10

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		can_be_hacked = false
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	elif anim.animation == "Shield Bash":
		anim.play("Walking")
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.5).timeout # 1-second attack delay
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
		

func attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	anim.play("Shield Bash")
	attack_hitbox.disabled = false
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.disabled = true
	is_attacking = false

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	if target and target.is_in_group("player"):
		target.take_damage(10, global_position)
