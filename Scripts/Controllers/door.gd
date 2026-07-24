extends Node2D


@onready var collision = $StaticBody2D/CollisionShape2D
@onready var sprite = $TileMapLayer



func set_open(open: bool):

	sprite.visible = !open

	collision.disabled = open
