extends Control

@onready var play_button: TextureButton = $Start

func _on_start_pressed() -> void:
	GameProgress.go_to_map()
