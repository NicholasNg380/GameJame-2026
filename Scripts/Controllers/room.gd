extends Node2D
class_name Room


var grid_position: Vector2i


@onready var north_door = $Doors/NorthDoor
@onready var east_door = $Doors/EastDoor
@onready var south_door = $Doors/SouthDoor
@onready var west_door = $Doors/WestDoor

@export var has_north_door := true
@export var has_east_door := true
@export var has_south_door := true
@export var has_west_door := true



func set_connections(north, east, south, west):
	north_door.set_open(north)
	east_door.set_open(east)
	south_door.set_open(south)
	west_door.set_open(west)
	
