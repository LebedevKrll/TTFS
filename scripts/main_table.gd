extends Node2D

var held_item = "" # "" / "gun" / "money"

func _ready() -> void:
	pass # Replace with function body.


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func pickup(item: String) -> void:
	held_item = item
