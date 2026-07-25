extends StaticBody2D

@export var INIT_VELOCITY: float = 1000.0
@export var pull_speed: float = 300.0


var current_velocity := 0.0
var friction := 450.0
var direction := Vector2.ZERO

const ANIM_TIMER_CONST := 1.0
var animate_timer := 0.0
var playerRef: Player = null
var enemy_lines := {}
var activated := false
var on_wall: bool = false
var damaged: bool = false
var enemies_to_kill: Array[Enemy] = []
var can_hit_wall := false
var can_hit_wall_timer := 0.05

@onready var light = $PointLight2D
@onready var anim = $AnimatedSprite2D
@onready var collision = $Area2D/CollisionShape2D

func _ready() -> void:
	#collision.disabled = true
	current_velocity = INIT_VELOCITY
	animate_timer = ANIM_TIMER_CONST
	anim.play("default")

func _process(delta: float) -> void:
	if can_hit_wall_timer <= 0:
		can_hit_wall = true
	can_hit_wall_timer -= delta
	
	if current_velocity > 0:
		current_velocity = max(current_velocity - friction * delta, 0)
		global_position += direction * current_velocity * delta
	else:
		if animate_timer <= 0:
			animate_timer = ANIM_TIMER_CONST
			light.visible = !light.visible
	if activated:
		if !is_instance_valid(playerRef):
			return
		var line: Line2D = enemy_lines[playerRef]

		line.set_point_position(0, line.to_local(global_position))
		line.set_point_position(1, line.to_local(playerRef.global_position))

		var dir = (global_position - playerRef.global_position).normalized()
		playerRef.velocity = dir * pull_speed
		if playerRef.global_position.distance_to(global_position) < 50 and !damaged:
			anim.play("explode")
			playerRef.take_damage(1)
			damaged = true
	animate_timer -= delta



func launch(start_pos: Vector2, dir: Vector2) -> void:
	global_position = start_pos
	direction = dir.normalized()
	rotation = direction.angle() # Optional: rotate to face travel direction

func stop_object():
	current_velocity = 0

func activate():
	current_velocity = 0
	collision.disabled = false
	activated = true

	
	var line := Line2D.new()
	line.width = 2
	line.texture = preload("res://Assets/Sprites/grapple_hook_body.png")
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	add_child(line)

	line.add_point(to_local(global_position))
	line.add_point(to_local(playerRef.global_position))

	enemy_lines[playerRef] = line


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if activated:
		return

	var player := area.get_parent() as Player
	playerRef = player
	activate()
		

func _on_collide_with_wall_body_entered(body: Node2D) -> void:
	if can_hit_wall:
		current_velocity = 0
		on_wall = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "explode":
		queue_free()
