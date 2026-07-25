class_name MapRoom
extends Area2D

signal selected(room: RoomController)

var ICONS = {
	RoomController.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	RoomController.Type.ROBOT: [preload("res://Assets/Sprites/Level.png"), Vector2.ONE],
	RoomController.Type.TREASURE: [preload("res://Assets/icon.svg"), Vector2.ONE],
	RoomController.Type.SHOP: [preload("res://Assets/Sprites/Shop.png"), Vector2(0.6, 0.6)],
	RoomController.Type.BOSS: [preload("res://Assets/icon.svg"), Vector2(1.25, 1.25)],
}

@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var line_2d: Line2D = $Visuals/Line2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false : set = set_available
var room: RoomController : set = set_room

#Test code
func _ready() -> void:
	var test_room = RoomController.new()
	test_room.type = RoomController.Type.SHOP
	test_room.position = Vector2(100, 100)
	room = test_room
	
	await get_tree().create_timer(3).timeout
	available = true

func set_available(new_value: bool) -> void:
	available = new_value
	
	if available:
		animation_player.play("highlight")
	elif not room.selected:
		animation_player.play("RESET")

func set_room(new_data: RoomController) -> void:
	room = new_data
	position = room.position
	line_2d.rotation_degrees = randi_range(0, 360)
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func show_selected() -> void:
	line_2d.modulate = Color.WHITE

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("attack"):
		return
		
	room.selected = true
	animation_player.play("select")
	
func _on_map_room_selected() -> void:
	selected.emit(room)
