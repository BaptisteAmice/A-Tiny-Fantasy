extends Control
class_name InventoryInterface

signal drop_slot_data(slot_data: SlotData)
signal force_close()

var grabbed_slot_data: SlotData
var external_inventory_owner: Node2D
var external_inventory_max_distance: float = 100

@onready var grabbed_slot: Slot = $GrabbedSlot
@onready var player_inventory: PlayerInventory = $PlayerInventory
@onready var external_inventory: PlayerInventory = $ExternalInventory
@onready var equip_inventory: PlayerInventory = $EquipInventory

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		var mouse_slot_offset: Vector2 = Vector2(5,5)
		grabbed_slot.global_position = get_global_mouse_position() + mouse_slot_offset
	
	# close external inventory if too far from it
	if external_inventory_owner:
		var distance: float = external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position())
		if distance > external_inventory_max_distance:
			force_close.emit()

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	
func set_player_equip_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	equip_inventory.set_inventory_data(inventory_data)

func set_external_inventory(p_external_inventory_owner: Node) -> void:
	external_inventory_owner = p_external_inventory_owner

	if not "inventory_data" in external_inventory_owner:
		push_error("External inventory owner '%s' does not have an 'inventory_data' property" % external_inventory_owner.name)
		return
	@warning_ignore("unsafe_property_access") # checked above
	var inventory_data: InventoryData = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()
	
func clear_external_inventory() -> void:
	if external_inventory_owner:
		if not "inventory_data" in external_inventory_owner:
			push_error("External inventory owner '%s' does not have an 'inventory_data' property" % external_inventory_owner.name)
			return
		
		@warning_ignore("unsafe_property_access") # checked above
		var inventory_data: InventoryData = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

func on_inventory_interact(inventory_data: InventoryData,
		index: int, button: int) -> void:
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()

func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func UpdateGrabbedSlot() -> void:
	if grabbed_slot_data != null:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and grabbed_slot_data:
		var mouse_event :InputEventMouseButton = event as InputEventMouseButton
		match mouse_event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		UpdateGrabbedSlot()


func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		UpdateGrabbedSlot()
