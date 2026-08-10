class_name DrinkSlot
extends Area2D

signal clicked(ware: Drink, slot: DrinkSlot)

@export var pool: Array[Drink]
var current_drink: Drink

@onready var sprite = $Sprite2D
@onready var collision := $CollisionShape2D

func _ready() -> void:
	input_event.connect(_on_input_event)

func restock() -> void:
	current_drink = pool.pick_random()
	sprite.texture = current_drink.texture
	collision.shape = current_drink.collision_shape
	visible = true
	input_pickable = true


func buy(current_money: int) -> bool:
	if current_money >= current_drink.price:
		return true
	return false

@warning_ignore("unused_parameter")
func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(current_drink, self)
