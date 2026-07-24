@tool
extends Node
class_name RoomController

const ROOM_SIZE := Vector2i(2048, 2048)

@export var total_rooms := 5

@export var room_start: PackedScene
@export var room_1: PackedScene

@onready var rooms_parent := $"../Rooms"

func _ready():
	generate_map()


func generate_map():

	# Delete old rooms
	for child in rooms_parent.get_children():
		child.queue_free()

	var directions = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]

	var occupied := {}

	var current_grid_pos := Vector2i.ZERO

	# ---------- START ROOM ----------
	var start_room = room_start.instantiate()
	start_room.position = current_grid_pos * ROOM_SIZE
	rooms_parent.add_child(start_room)

	occupied[current_grid_pos] = true

	# ---------- FIRST ROOM (always above) ----------
	current_grid_pos += Vector2i.UP

	var first_room = room_1.instantiate()
	first_room.position = current_grid_pos * ROOM_SIZE
	rooms_parent.add_child(first_room)

	occupied[current_grid_pos] = true

	# ---------- REMAINING ROOMS ----------
	for i in range(total_rooms - 2):

		var valid_dirs := []

		for dir in directions:
			if !occupied.has(current_grid_pos + dir):
				valid_dirs.append(dir)

		if valid_dirs.is_empty():
			break

		var chosen_dir = valid_dirs.pick_random()
		current_grid_pos += chosen_dir

		occupied[current_grid_pos] = true

		var room = room_1.instantiate()
		room.position = current_grid_pos * ROOM_SIZE
		rooms_parent.add_child(room)
