extends Node

var map_data: Array[Array] = []
var floors_climbed: int = 0
var last_room: RoomController = null
var has_map: bool = false

func store(map_data_in: Array[Array], floors_climbed_in: int, last_room_in: RoomController) -> void:
	map_data = map_data_in
	floors_climbed = floors_climbed_in
	last_room = last_room_in
	has_map = true

func clear() -> void:
	map_data = []
	floors_climbed = 0
	last_room = null
	has_map = false
