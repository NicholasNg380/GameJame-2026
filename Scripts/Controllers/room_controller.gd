@tool
extends Node
class_name RoomController


const ROOM_SIZE := Vector2i(2048, 2048)


@export var total_rooms := 5

@export var room_start: PackedScene

# Add all possible rooms here
@export var room_types: Array[PackedScene]


@onready var rooms_parent := $"../Rooms"


var rooms: Array = []
var occupied: Dictionary = {}



func _ready():
	generate_map()



func generate_map():

	# Delete old rooms
	for child in rooms_parent.get_children():
		child.queue_free()


	rooms.clear()
	occupied.clear()


	var directions = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]


	var current_grid_pos := Vector2i.ZERO


	# -------------------
	# Start Room
	# -------------------

	spawn_room(room_start, current_grid_pos)



	# -------------------
	# First Room (always up)
	# -------------------

	current_grid_pos += Vector2i.UP

	spawn_room(get_random_room(), current_grid_pos)



	# -------------------
	# Other Rooms
	# -------------------

	for i in range(total_rooms - 2):

		var valid_dirs := []


		for dir in directions:

			var next_position = current_grid_pos + dir

			if !occupied.has(next_position):
				valid_dirs.append(dir)



		if valid_dirs.is_empty():
			break



		var chosen_dir = valid_dirs.pick_random()

		current_grid_pos += chosen_dir


		spawn_room(get_random_room(), current_grid_pos)



	# Once all rooms exist, update corridors
	update_room_connections()




func get_random_room() -> PackedScene:

	return room_types.pick_random()




func spawn_room(scene: PackedScene, grid_pos: Vector2i):

	var room = scene.instantiate()


	# Position in world
	room.position = grid_pos * ROOM_SIZE


	# Give room its grid location
	room.grid_position = grid_pos


	rooms_parent.add_child(room)


	# Save references
	rooms.append(room)

	occupied[grid_pos] = room





func update_room_connections():

	for room in rooms:

		var pos = room.grid_position


		var north_open = occupied.has(pos + Vector2i.UP)
		var east_open = occupied.has(pos + Vector2i.RIGHT)
		var south_open = occupied.has(pos + Vector2i.DOWN)
		var west_open = occupied.has(pos + Vector2i.LEFT)


		room.set_connections(
			north_open,
			east_open,
			south_open,
			west_open
		)
