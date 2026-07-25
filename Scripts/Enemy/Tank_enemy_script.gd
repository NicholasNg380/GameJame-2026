extends "Enemy_script.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SPEED = 225
	type = "Tank"

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	if anim.animation == "Shield Bash":
		anim.play("Walking")
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.5).timeout # 1-second attack delay
		current_state = State.CHASE

func attack() -> void:
	anim.play("Shield Bash")


func _on_damaging_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	anim.play("Hit")
	var direction = global_position.direction_to(player.global_position)
	velocity += -direction*SPEED
