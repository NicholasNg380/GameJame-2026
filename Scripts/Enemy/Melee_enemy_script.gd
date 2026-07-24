extends "Enemy_script.gd"

var type = "Sword"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	SPEED = 500


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func attack() -> void:
	anim.play("Left Slash")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Waking up":
		spawning = false
		current_state = State.CHASE
		anim.play("Walking")
	if anim.animation == "Left Slash":
		anim.play("Walking")
		current_state = State.COOLDOWN
		await get_tree().create_timer(0.5).timeout # 1-second attack delay
		current_state = State.CHASE
