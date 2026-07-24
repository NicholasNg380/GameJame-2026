extends "Enemy_script.gd"

var type = "Magnet"

func _ready():
	super()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		on = true
		anim.play("Walking")
