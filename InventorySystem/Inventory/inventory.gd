extends PanelContainer
class_name PlayerInventory

const SLOT: PackedScene = preload("res://InventorySystem/Inventory/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	inventory_data.inventory_updated.connect(call_sync_player_inventories_to_server)
	
	populate_item_grid(inventory_data)
	
func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InventoryData) -> void:
	# remove current children
	for child: Node in item_grid.get_children():
		child.queue_free()
		
	for slot_data: SlotData in inventory_data.slot_datas:
		var slot: Slot = SLOT.instantiate() as Slot
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)

func call_sync_player_inventories_to_server(inventory_data: InventoryData) -> void:
	PlayerManager.my_player.sync_player_inventories_to_server()
