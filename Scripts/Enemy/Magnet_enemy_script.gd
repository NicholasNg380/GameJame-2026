extends Enemy

@onready var hitbox = $"Damaging Hitbox/CollisionShape2D"

func _ready():
	super()
	SPEED = 550
	type = "Magnet"
	health = 5

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
		
		
func attack():
	anim.play("Spit")
	
func _on_damaging_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if !knocked:
		current_state = State.HIT
		health -= 1
	elif knocked and can_be_hacked:
		can_be_hacked = false
		anim.play("Death")
		
	
