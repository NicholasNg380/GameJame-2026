extends Node2D
class_name Door

@onready var collision = $StaticBody2D/CollisionShape2D
@onready var sprite = $TileMapLayer
@onready var occluder = $LightOccluder2D

var original_occluder: OccluderPolygon2D


func _ready():
	if occluder.occluder == null:
		push_warning(name + " has no LightOccluder2D polygon!")
	else:
		original_occluder = occluder.occluder

func set_open(open: bool):

	sprite.visible = !open
	collision.disabled = open

	if open:
		occluder.occluder = null
	else:
		occluder.occluder = original_occluder
