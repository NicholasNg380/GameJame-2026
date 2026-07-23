extends "Enemy_script.gd"


@onready var anim = $Sword



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	anim.play("Walking")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
