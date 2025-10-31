extends PanelContainer
class_name HotBarInventory

signal hot_bar_use(index: int)

const SLOT: PackedScene = preload("uid://8irnp68kgu1a")
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

var length : int = 0

func match_hotbar_length_to_inventory() -> void:
	length = Global.get_world_scene().inventory_interface.player_inventory.item_grid.columns


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return 
	
	#use items with numbers
	@warning_ignore("unsafe_property_access")
	if range(KEY_1, KEY_1 + length).has(event.keycode):
		@warning_ignore("unsafe_property_access")
		hot_bar_use.emit(event.keycode - KEY_1)
		

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	match_hotbar_length_to_inventory()
	hot_bar_use.connect(inventory_data.use_slot_data)
	populate_hot_bar(inventory_data)

func populate_hot_bar(inventory_data: InventoryData) -> void:
	for children: Node in h_box_container.get_children():
		children.queue_free()

	for slot_data: SlotData in inventory_data.slot_datas.slice(0,length):
		var slot_instance: Slot = SLOT.instantiate()
		h_box_container.add_child(slot_instance)

		if slot_data:
			slot_instance.set_slot_data(slot_data)
