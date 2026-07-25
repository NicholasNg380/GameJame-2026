class_name MapGenerator
extends Node

const X_DIST = 30
const Y_DIST = 25
const PLACEMENT_RANDMONESS = 5
const FLOORS = 15
const MAP_WIDTH = 7
const PATHS = 6
const ROBOT_ROOM_WEIGHT = 10.0
const SHOP_ROOM_WEIGHT = 2.5

var random_room_type_weights = {
	RoomController.Type.ROBOT: 0.0,
	RoomController.Type.SHOP: 0.0
}
var random_room_type_total_weight = 0
var map_data: Array[Array]

func generate_map() -> Array[Array]:
	map_data = _generate_inital_grid()
	var starting_points = _get_random_starting_points()
	
	for j in starting_points:
		var current_j = j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)
			
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()
	
	return map_data
	
func _generate_inital_grid() -> Array[Array]:
	var grid: Array[Array] = []
	
	for i in FLOORS:
		var adjacent_rooms: Array[RoomController] = []
		
		for j in MAP_WIDTH:
			var current_room := RoomController.new()
			var offset = Vector2(randf(), randf()) * PLACEMENT_RANDMONESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = [] 
			
			if i == FLOORS - 1:
				current_room.position.y = (i + 1) * -Y_DIST
				
			adjacent_rooms.append(current_room)
				
		grid.append(adjacent_rooms)
		
	return grid

func _get_random_starting_points() -> Array[int]:
	var y_coords: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coords = []
		
		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coords.has(starting_point):
				unique_points += 1
				
			y_coords.append(starting_point)
	
	return(y_coords)
	
func _setup_connection(i: int, j: int) -> int:
	var next_room: RoomController
	var current_room = map_data[i][j] as RoomController
	
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j = clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][random_j]
		
	current_room.next_rooms.append(next_room)
	
	return next_room.column
	
func _would_cross_existing_path(i: int, j:int, room: RoomController) -> bool:
	var left_node: RoomController
	var right_node: RoomController
	
	if j > 0:
		left_node = map_data[i][j - 1]
	if j < MAP_WIDTH - 1:
		right_node = map_data[i][j + 1]
		
	if right_node and room.column > j:
		for next_room: RoomController in right_node.next_rooms:
			if next_room.column < room.column:
				return true
				
	if left_node and room.column < j:
		for next_room: RoomController in left_node.next_rooms:
			if next_room.column > room.column:
				return true
				
	return false

func _setup_boss_room() -> void:
	var middle = floori(MAP_WIDTH * 0.5)
	var boss_room = map_data[FLOORS - 1][middle] as RoomController
	
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS - 2][j] as RoomController
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[RoomController]
			current_room.next_rooms.append(boss_room)
			
	boss_room.type = RoomController.Type.BOSS 
	
func _setup_random_room_weights() -> void:
	random_room_type_weights[RoomController.Type.ROBOT] = ROBOT_ROOM_WEIGHT
	random_room_type_weights[RoomController.Type.SHOP] = ROBOT_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[RoomController.Type.SHOP]
	
func _setup_room_types() -> void:
	
	# First room is always battle
	for room: RoomController in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = RoomController.Type.ROBOT
	
	# 3rd room is always shop
	for room: RoomController in map_data[2]:
		if room.next_rooms.size() > 0:
			room.type = RoomController.Type.SHOP
			
	for current_floor in map_data:
		for room: RoomController in current_floor:
			for next_room: RoomController in room.next_rooms:
				if next_room.type == RoomController.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)
					
func _set_room_randomly(room_to_set: RoomController) -> void:
	var consecutive_shop = true
	
	var type_candidate: RoomController.Type
	
	while consecutive_shop:
		type_candidate = _get_random_room_type_by_weight()
		
		var is_shop = type_candidate == RoomController.Type.SHOP
		var has_shop_parent = _room_has_parent_of_type(room_to_set, RoomController.Type.SHOP)
		
		consecutive_shop = is_shop and has_shop_parent
		
	room_to_set.type = type_candidate
	
func _room_has_parent_of_type(room: RoomController, type: RoomController.Type) -> bool:
	var parents: Array[RoomController] = []
	
	if room.column > 0 and room.row > 0:
		var parent_candidate = map_data[room.row - 1][room.column - 1] as RoomController
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
			
	if room.row > 0:
		var parent_candidate = map_data[room.row - 1][room.column] as RoomController
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
			
	if room.column < MAP_WIDTH - 1 and room.row > 0:
		var parent_candidate = map_data[room.row - 1][room.column + 1] as RoomController
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
			
	for parent: RoomController in parents:
		if parent.type == type:
			return true
	
	return false
	
func _get_random_room_type_by_weight() -> RoomController.Type:
	var roll = randf_range(0.0, random_room_type_total_weight)
		
	for type: RoomController.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
		
	return RoomController.Type.ROBOT
		
	
