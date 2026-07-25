extends StaticBody2D

@export var INIT_VELOCITY: float = 1000.0

var current_velocity := 0.0
var friction := 450.0
var direction := Vector2.ZERO

const ANIM_TIMER_CONST := 1.0
var animate_timer := 0.0

@onready var light = $PointLight2D
@onready var anim = $AnimatedSprite2D
@onready var collision = $Area2D/CollisionShape2D

func _ready() -> void:
	collision.disabled = true
	current_velocity = INIT_VELOCITY
	animate_timer = ANIM_TIMER_CONST
	anim.play("default")

func _process(delta: float) -> void:
	if current_velocity > 0:
		current_velocity = max(current_velocity - friction * delta, 0)
		global_position += direction * current_velocity * delta
	else:
		if animate_timer <= 0:
			animate_timer = ANIM_TIMER_CONST
			light.visible = !light.visible

	animate_timer -= delta

func launch(start_pos: Vector2, dir: Vector2) -> void:
	global_position = start_pos
	direction = dir.normalized()
	rotation = direction.angle() # Optional: rotate to face travel direction

func stop_object():
	current_velocity = 0

func activate():
	collision.disabled = false
