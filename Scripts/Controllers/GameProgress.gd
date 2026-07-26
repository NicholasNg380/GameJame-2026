extends Node

signal level_completed(level_id)

var levels: Array = [
	{"id": "level_1", "name": "Level 1", "scene": "res://Scenes/World.tscn", "unlocked": true, "cleared": false},
	{"id": "level_2", "name": "Level 2", "scene": "res://Scenes/World2.tscn", "unlocked": false, "cleared": false},
	{"id": "level_3", "name": "Level 3", "scene": "res://Scenes/World3.tscn", "unlocked": false, "cleared": false},
]

var current_level_index: int = -1

func get_level(index: int) -> Dictionary:
	return levels[index]

func select_level(index: int) -> void:
	current_level_index = index

func start_selected_level() -> void:
	if current_level_index < 0:
		return
	get_tree().change_scene_to_file(levels[current_level_index]["scene"])

func complete_current_level() -> void:
	if current_level_index < 0:
		return
	levels[current_level_index]["cleared"] = true
	var next_index = current_level_index + 1
	if next_index < levels.size():
		levels[next_index]["unlocked"] = true
	level_completed.emit(levels[current_level_index]["id"])

func go_to_map() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Map/Map.tscn")

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/start_screen.tscn")
