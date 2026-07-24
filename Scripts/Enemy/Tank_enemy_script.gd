extends "Enemy_script.gd"

var type = "Tank"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		on = true
		anim.play("Walking")
