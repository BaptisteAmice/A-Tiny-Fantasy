extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 99

@export var item_data: ItemData
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quantity

# can fully merge both stacks into one
func can_fully_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
	and item_data.stackable \
	and quantity + other_slot_data.quantity <= MAX_STACK_SIZE

# can merge one item	
func can_merge_with(other_slot_data: SlotData) -> bool:
	return item_data == other_slot_data.item_data \
	and item_data.stackable \
	and quantity < MAX_STACK_SIZE

func fully_merge_with(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity

func create_single_slot_data() -> SlotData:
	var new_slot_data: SlotData = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func set_quantity(value: int) -> void:
	quantity = value
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item_data.name)

func save() -> Dictionary:
	return {
		"item_path": item_data.resource_path, # store the Resource path
		"quantity": quantity,
	}

func load(saved_state: Dictionary) -> void:
	if not saved_state.has("item_path") or not saved_state.has("quantity"):
		push_error("Invalid saved_state for SlotData: ", saved_state)
		return
	var path: String = saved_state["item_path"]
	if path == "":
		item_data = null
		return
	# Load the resource from path
	var res: Resource = ResourceLoader.load(path)
	if res:
		item_data = res
		quantity = saved_state["quantity"] # need to set quantity after item_data
	else:
		push_error("Failed to load item resource at: ", path)
		item_data = null
