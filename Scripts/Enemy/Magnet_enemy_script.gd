extends Enemy



func _ready():
	super()
	SPEED = 550
	type = "Magnet"

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	if anim.animation == "Spit":
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.5).timeout # 1-second attack delay
		anim.play("Walking")
		current_state = State.CHASE
	if anim.animation == "Hit":
		current_state = State.CHASE
		
func attack():
	anim.play("Spit")
	
func _on_damaging_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	current_state = State.HIT
	
