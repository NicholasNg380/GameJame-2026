@tool
extends Node
class_name RoomController

@export var map_dimensions: Vector2i = Vector2i(16,16)
@export var total_steps: int = 5
@export var tilemap_layer: TileMapLayer

func _ready() -> void:
	generate_map()
	
func generate_map() -> void:
	pass

func draw_tile_rect(dimensions: Vector2i, source_id: int, atlas_coords: Vector2i) -> void:
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tilemap_layer.set_cell(Vector2(x,y), source_id, atlas_coords)
