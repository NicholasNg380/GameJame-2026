extends "Enemy_script.gd"

var type = "Sword"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SPEED = 500


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	if anim.animation == "Left Slash":
		current_state = State.CHASE
		anim.play("Walking")
