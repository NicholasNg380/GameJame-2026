extends StaticBody2D

var INIT_VELOCITY: float = 200

var current_velocity := 0.0
var friction := 80.0

const ANIM_TIMER_CONST := 1.0
var animate_timer := 0.0

@onready var light = $PointLight2D
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready() -> void:
	print("HELLO")
	
	collision.disabled = true
	current_velocity = INIT_VELOCITY
	animate_timer = ANIM_TIMER_CONST
	anim.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_velocity > 0:
		current_velocity -= friction
	else:
		current_velocity = 0
		if animate_timer == 0:
			animate_timer = ANIM_TIMER_CONST
			light.visible = !light.visible
	animate_timer -= delta
	
func stop_object():
	current_velocity = 0

func activate():
	collision.disabled = false
	
	
