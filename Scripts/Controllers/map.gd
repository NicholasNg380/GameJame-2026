class_name Map
extends Node2D

const SCROLL_SPEED = 15
const MAP_ROOM = preload("res://Scenes/UI/Map/MapRoom.tscn")
const MAP_LINE = preload("res://Scenes/UI/Map/MapLine.tscn")
const WORLD_EASY = "res://Scenes/Levels/WorldEasy.tscn"
const WORLD_MEDIUM = "res://Scenes/Levels/WorldMedium.tscn"
const WORLD_HARD = "res://Scenes/Levels/WorldHard.tscn"

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera_2d: Camera2D = $Camera2D

var map_data: Array[Array]
var floors_climbed: int
var last_room: RoomController
var camera_edge_y: float

func _ready() -> void:
	
	camera_edge_y = MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)
	
	if MapProgress.has_map:
		_restore_map()
	else:
		generate_new_map()
		unlock_floor(0)

func _restore_map() -> void:
	map_data = MapProgress.map_data
	floors_climbed = MapProgress.floors_climbed
	last_room = MapProgress.last_room
	create_map()

	if last_room:
		unlock_next_rooms()
	else:
		unlock_floor(0)
	
func _input(event: InputEvent) -> void:
	if event.is_action("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
	elif event.is_action("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED

func generate_new_map() -> void:
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()
	
func create_map() -> void:
	for current_floor: Array in map_data:
		for room: RoomController in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
				
	# Boss Room
	var middle = floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_room(map_data[MapGenerator.FLOORS - 1][middle])
	
	var map_width_pixels = MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2
	
func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true
			
func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		map_room.available = false
	
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true
			
func show_map() -> void:
	show()
	camera_2d.enable = true
	
func hide_map() -> void:
	hide()
	camera_2d.enable = false

func _spawn_room(room: RoomController) -> void:
	var new_map_room = MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()
		
func _connect_lines(room: RoomController) -> void:
	if room.next_rooms.is_empty():
		return
	
	for next: RoomController in room.next_rooms:
		var new_map_line = MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)
		
func _on_map_room_selected(room: RoomController) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
			
			
	last_room = room
	floors_climbed += 1
	unlock_next_rooms()
	
	_load_world_for_room(room)

func _load_world_for_room(room: RoomController) -> void:
	MapProgress.store(map_data, floors_climbed, last_room)
	
	match room.type:
		RoomController.Type.EASY:
			get_tree().change_scene_to_file(WORLD_EASY)
		RoomController.Type.MEDIUM:
			get_tree().change_scene_to_file(WORLD_MEDIUM)
		RoomController.Type.HARD, RoomController.Type.BOSS:
			get_tree().change_scene_to_file(WORLD_HARD)
		RoomController.Type.SHOP:
			pass # no shop scene yet — add when ready
