extends "Enemy_script.gd"

var type = "Tank"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SPEED = 250

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
