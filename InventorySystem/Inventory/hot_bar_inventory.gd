extends PanelContainer
class_name HotBarInventory

signal hot_bar_use(index: int)
signal active_item_updated()

const SLOT: PackedScene = preload("uid://8irnp68kgu1a")
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer

var length : int = 0 # will be updated when the inventory is set
var active_item_slot: int = 0

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
		

func use_active_item() -> void:
	hot_bar_use.emit(active_item_slot)

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	match_hotbar_length_to_inventory()
	hot_bar_use.connect(inventory_data.use_slot_data)
	populate_hot_bar(inventory_data)

func populate_hot_bar(inventory_data: InventoryData) -> void:
	for children: Node in h_box_container.get_children():
		children.queue_free()
	
	await get_tree().process_frame # sleep needed to wait for queue free to be really effective on active item use (not the best practice, but it's for display so we don't care that much)

	for i: int in range(length):
		var slot_data: SlotData = inventory_data.slot_datas[i]
		var slot_instance: Slot = SLOT.instantiate()
		h_box_container.add_child(slot_instance)
		# connect signals
		connect("active_item_updated", Callable(slot_instance, "refresh_style"))

		if slot_data:
			slot_instance.set_slot_data(slot_data)
	
	#emit signal to update active item style
	emit_signal("active_item_updated")

func active_item_scroll_up() -> void:
	if length == 0:
		push_warning("HotBarInventory: active_item_scroll_up called with length 0")
		return
	active_item_slot = (active_item_slot - 1 + length) % length
	emit_signal("active_item_updated")

func active_item_scroll_down() -> void:
	if length == 0:
		push_warning("HotBarInventory: active_item_scroll_down called with length 0")
		return
	active_item_slot = (active_item_slot + 1) % length
	emit_signal("active_item_updated")
