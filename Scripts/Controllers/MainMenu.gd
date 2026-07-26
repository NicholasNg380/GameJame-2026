extends Control

@onready var play_button: TextureButton = $Start

func _on_start_pressed() -> void:
	MapProgress.clear()
	get_tree().change_scene_to_file("res://Scenes/UI/Map/Map.tscn")
