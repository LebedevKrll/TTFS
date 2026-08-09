class_name WareSlot
extends Area2D

signal clicked(ware: Ware, slot: WareSlot)

@export var pool: Array[Ware]
var current_ware: Ware

@onready var sprite = $Sprite2D
@onready var collision := $CollisionShape2D

func _ready() -> void:
	input_event.connect(_on_input_event)
	consume()

func restock() -> void:
	current_ware = pool.pick_random()

func reveal() -> void:
	sprite.texture = current_ware.texture
	collision.shape = current_ware.collision_shape
	visible = true
	input_pickable = true

func consume() -> void:
	visible = false
	input_pickable = false

func buy() -> void:
	consume()
	current_ware = null

@warning_ignore("unused_parameter")
func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(current_ware, self)
