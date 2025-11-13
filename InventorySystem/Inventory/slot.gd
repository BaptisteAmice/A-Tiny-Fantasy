extends PanelContainer
class_name Slot

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel
@onready var selected_texture_rect: TextureRect = $SelectedTextureRect

func set_slot_data(slot_data: SlotData) -> void:
	var item_data: ItemData = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]

	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event : InputEventMouseButton = event as InputEventMouseButton
		if (mouse_event.button_index == MOUSE_BUTTON_LEFT \
				or mouse_event.button_index == MOUSE_BUTTON_RIGHT) \
				and mouse_event.is_pressed():
			slot_clicked.emit(get_index(), mouse_event.button_index)

func refresh_style() -> void:
	var hot_bar_inventory: HotBarInventory = Global.get_world_scene().hot_bar_inventory
	print("Refreshing style for slot %s, active slot is %s" % [get_index(), hot_bar_inventory.active_item_slot])
	if hot_bar_inventory.active_item_slot == get_index():
		selected_texture_rect.show()
	else:
		selected_texture_rect.hide()
