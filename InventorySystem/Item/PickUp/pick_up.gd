extends RigidBody2D
class_name PickUp

@export var slot_data: SlotData
@onready var sprite_2d: Sprite2D = $Sprite2D
var dropped_by: Node2D

func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (not dropped_by == body):
		if not "inventory_data" in body:
			push_error("Body '%s' does not have property 'inventory_data'" % body.name)
			return
		@warning_ignore("unsafe_method_access", "unsafe_property_access") # checked above
		if await body.inventory_data.pick_up_slot_data(slot_data):
			queue_free()
