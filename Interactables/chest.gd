extends InteractableArea
class_name Chest

#todo add save

signal toggle_inventory(external_inventory_owner: Node)
@export var inventory_data: InventoryData

# Flag to prevent infinite loops when syncing inventory between client and server
var is_syncing_from_server : bool = false

func _ready() -> void:
	inventory_data.inventory_updated.connect(call_sync_chest_inventory_from_client)

func player_interact()->void:
	toggle_inventory.emit(self)

########### Multiplayer inventory syncing ###########

func call_sync_chest_inventory_from_client(chest_inventory: InventoryData) -> void:
	if multiplayer.is_server():
		print("Only the player can sync their inventory to the server!")
		return
	# Avoid infinite loops when syncing inventory between client and server
	if is_syncing_from_server: return
	# Send inventory to server
	rpc_id(1, "sync_chest_inventory_from_client", chest_inventory.save())
	
@rpc("any_peer")
func sync_chest_inventory_from_client(chest_inventory: Dictionary) -> void:
	if !multiplayer.is_server():
		print("Only the server can receive inventory updates from clients!")
		return
	inventory_data.load(chest_inventory)
	# Send inventory to all clients
	rpc("sync_chest_inventory_from_server", chest_inventory)

@rpc("any_peer")
func sync_chest_inventory_from_server(chest_inventory: Dictionary) -> void:
	if multiplayer.is_server():
		print("Only clients can receive inventory updates from the server!")
		return
	is_syncing_from_server = true
	inventory_data.load(chest_inventory)
	is_syncing_from_server = false
