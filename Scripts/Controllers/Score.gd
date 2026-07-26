extends Node

var score: int = 0

var combo: float = 1.0
var combo_minimum: float = 1.0

signal score_changed(value)
signal combo_changed(value)

func set_room_difficulty(type: RoomController.Type):
	match type:
		"EASY":
			combo_minimum = 1.0
		"MEDIUM":
			combo_minimum = 1.5
		"HARD":
			combo_minimum = 2.0
	
	combo = combo_minimum
	combo_changed.emit(combo)

func hit_enemy():
	score += int(10 * combo)
	score_changed.emit(score)

func kill_enemy():
	score += int(50 * combo)
	increase_combo()

func hack_enemy():
	increase_combo()

func increase_combo():
	combo += 0.1
	combo_changed.emit(combo)

func player_hit():
	combo = combo_minimum
	combo_changed.emit(combo)
