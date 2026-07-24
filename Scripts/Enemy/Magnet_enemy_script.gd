extends Enemy

var type = "Magnet"

func _ready():
	super()
	SPEED = 750

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
