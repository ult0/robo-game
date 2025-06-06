extends Object
class_name PriorityQueue
"""
Priority Queue. Min heap priority queue that can take a Vector2 and its
corresponding cost and then always return the Vector2 in it with
the lowest cost value.
Based on: https://en.wikipedia.org/wiki/Binary_heap
"""
var dict: Dictionary[Variant, float]
var data: Array[Variant]

func _init() -> void:
	dict = {}
	data = []

func insert(element: Variant, cost: float) -> void:
	# Add the element to the bottom level of the heap at the leftmost open space
	data.push_back(element)
	dict[element] = cost
	var new_element_index: int = data.size() - 1
	_up_heap(new_element_index)

func extract() -> Variant:
	if is_empty():
		return null

	# Store the element to return later
	var result: Variant = data[0]

	# If this was the last element, just remove it
	if data.size() == 1 and dict.size() == 1:
		data.pop_back()
		dict.erase(result)
		return result

	# Replace root with last element and remove last element
	data[0] = data.pop_back()
	dict.erase(result)
	_down_heap(0)

	return result

func modify(index: int, new_element: Variant, new_cost: float) -> void:
	var old_element = data[index]
	var old_cost = dict[data[index]]
	data[index] = new_element
	dict[data[index]] = new_cost
	dict.erase(old_element)
	# If the new cost is less than the old cost, we need to up-heap
	if new_cost < old_cost:
		_up_heap(index)
	else:
		_down_heap(index)

func is_empty() -> bool:
	return data.is_empty()

func _get_parent(index: int) -> int:
	return (index - 1) / 2

func _left_child(index: int) -> int:
	return (2 * index) + 1

func _right_child(index: int) -> int:
	return (2 * index) +  2

func _swap(a_idx: int, b_idx: int) -> void:
	var a = data[a_idx]
	var b = data[b_idx]
	data[a_idx] = b
	data[b_idx] = a

func _up_heap(index: int) -> void:
	# If we're at the root (index 0), we can't go up further
	if index <= 0:
		return
	
	# Compare the added element with its parent; if they are in the correct order, stop.
	var parent_idx = _get_parent(index)
	if dict[data[index]] >= dict[data[parent_idx]]:
		return
	_swap(index, parent_idx)
	_up_heap(parent_idx)

func _down_heap(index: int) -> void:
	var left_idx: int = _left_child(index)
	var right_idx: int = _right_child(index)
	var smallest: int = index
	var size: int = data.size()

	if left_idx < size and dict[data[left_idx]] < dict[data[smallest]]:
		smallest = left_idx
	
	if right_idx < size and dict[data[right_idx]] < dict[data[smallest]]:
		smallest = right_idx

	if smallest != index:
		_swap(index, smallest)
		_down_heap(smallest)
