extends Node2D
class_name World

const PICKUP: PackedScene = preload("uid://dbkewafchkam1")

@onready var multiplayer_spawner: MultiplayerSpawnerOfPlayer = $MultiplayerSpawner
@onready var player_selection: PlayerSelection = $CanvasLayer/PlayerSelection

@onready var inventory_interface: InventoryInterface = $CanvasLayer/InventoryInterface
@onready var hot_bar_inventory: HotBarInventory = $CanvasLayer/HotBarInventory



func setup_local_player(player: Player) -> void:
	# Only clients should call this
	if multiplayer.is_server():
		push_error("Only clients should set up the local player!")
		return
	# Ensure we only set up the local player once
	if PlayerManager.my_player != null:
		#todo set player to null on disconnect
		push_error("Local player is already set up!")
		return
	# Set the local reference to the player
	PlayerManager.my_player = player
	# setup inventory interface
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(PlayerManager.my_player.inventory_data)
	inventory_interface.set_player_equip_inventory_data(PlayerManager.my_player.equip_inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	hot_bar_inventory.set_inventory_data(PlayerManager.my_player.inventory_data)
	
	for node: Node in get_tree().get_nodes_in_group("external_inventory"):
		if node.has_signal("toggle_inventory"):
			@warning_ignore("unsafe_property_access", "unsafe_method_access") # checked above
			node.toggle_inventory.connect(toggle_inventory_interface)
		else:
			push_error("Node '%s' in group 'external_inventory' does not have a 'toggle_inventory' signal" % node.name)

	print("Local player set up:", PlayerManager.my_player)

func toggle_inventory_interface(external_inventory_owner: Node = null) -> void:
	inventory_interface.visible = not inventory_interface.visible

	if inventory_interface.visible:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hot_bar_inventory.hide()
	else:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hot_bar_inventory.show()
		
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_save_button_pressed() -> void:
	Global.game_controller.save_manager.request_save_data()


func _on_exit_button_pressed() -> void:
	#  Save data
	Global.game_controller.save_manager.request_save_data()
	# Disconnect from the server
	Global.game_controller.network_manager.disconnect_client()
	# return to main menu 
	Global.game_controller.change_scene("res://Menus/main_menu.tscn")


func _on_close_server_button_pressed() -> void:
	Global.game_controller.network_manager.close_server()


func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up: PickUp = PICKUP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = PlayerManager.my_player.get_drop_position()
	pick_up.dropped_by = PlayerManager.my_player
	add_child(pick_up)
