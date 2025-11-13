extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]

#todo implement, todo use subscriber pattern to notify connected inventories of changes
# Allow tranfer of items from inventory to inventory (for exemple with pipes)
var connected_input_inventories: Array[InventoryData] # only needed for stats and display
var blocked_input_items: Array[ItemData] # items that can't enter
var connected_output_inventories: Array[InventoryData]
var blocked_output_items: Array[ItemData] # items that can't exit
var locked_output_slots: Array[int] # locked slots
var outputs_per_second: int = 0 # takes the speed of the worst connected pipe
# to handle priority for interactables with several inventories (eg. furnace)
@export var item_priorities: Dictionary[Constants.ITEM_TAG, Constants.PRIORITY]

func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
	
func grab_slot_data(index: int) -> SlotData:
	var slot_data: SlotData = slot_datas[index]
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null
	
func drop_slot_data(grabbed_slot_data: SlotData,index: int) -> SlotData:
	var slot_data : SlotData = slot_datas[index]
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data

	inventory_updated.emit(self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data: SlotData,index: int) -> SlotData:
	var slot_data : SlotData = slot_datas[index]
	
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func use_slot_data(index: int) -> void:
	var slot_data: SlotData = slot_datas[index]
	if not slot_data:
		return
	
	if slot_data.item_data is ItemDataUsable:
		if slot_data.item_data.consumable:
			slot_data.quantity -= 1
			if slot_data.quantity < 1:
				slot_datas[index] = null
	PlayerManager.use_slot_data(slot_data)
	inventory_updated.emit(self)
	
func pick_up_slot_data(slot_data: SlotData) -> bool:
	for index: int in slot_datas.size():
		# if there is a mergable slot, merge with it
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data): 
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	# if there is space for it, add the item to the inventory
	for index: int in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	return false
	
func save() -> Dictionary:
	var saved_slots: Array = []
	for slot: SlotData in slot_datas:
		if slot:
			saved_slots.append(slot.save()) # assume SlotData has a save() method
		else:
			saved_slots.append(null)
	return {"slots": saved_slots}

func load(saved_state: Dictionary) -> void:
	var saved_slots: Array = saved_state.get("slots", [])
	for i: int in range(saved_slots.size()):
		if saved_slots[i]:
			if slot_datas.size() <= i:
				slot_datas.resize(i + 1)
			slot_datas[i] = SlotData.new()
			var saved_slot_i: Dictionary = saved_slots[i]
			slot_datas[i].load(saved_slot_i)
		else:
			if slot_datas.size() > i:
				slot_datas[i] = null
	emit_signal("inventory_updated", self)
