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
	self.data.push_back(element)
	self.dict[element] = cost
	var new_element_index: int = self.data.size() - 1
	self._up_heap(new_element_index)

func extract() -> Variant:
	if self.is_empty():
		return null

	# Store the element to return later
	var result: Variant = self.data[0]

	# If this was the last element, just remove it
	if self.data.size() == 1 and self.dict.size() == 1:
		self.data.pop_back()
		self.dict.erase(result)
		return result

	# Replace root with last element and remove last element
	self.data[0] = self.data.pop_back()
	self.dict.erase(result)
	self._down_heap(0)

	return result

func modify(index: int, new_element: Variant, new_cost: float) -> void:
	var old_cost = self.dict[self.data[index]]
	self.data[index] = new_element
	self.dict[self.data[index]] = new_cost
	# If the new cost is less than the old cost, we need to up-heap
	if new_cost < old_cost:
		self._up_heap(index)
	else:
		self._down_heap(index)

func is_empty() -> bool:
	return self.data.is_empty()

func _get_parent(index: int) -> int:
	return (index - 1) / 2

func _left_child(index: int) -> int:
	return (2 * index) + 1

func _right_child(index: int) -> int:
	return (2 * index) +  2

func _swap(a_idx: int, b_idx: int) -> void:
	var a = self.data[a_idx]
	var b = self.data[b_idx]
	self.data[a_idx] = b
	self.data[b_idx] = a

func _up_heap(index: int) -> void:
	# If we're at the root (index 0), we can't go up further
	if index <= 0:
		return
	
	# Compare the added element with its parent; if they are in the correct order, stop.
	var parent_idx = self._get_parent(index)
	if self.dict[self.data[index]] >= self.dict[self.data[parent_idx]]:
		return
	self._swap(index, parent_idx)
	self._up_heap(parent_idx)

func _down_heap(index: int) -> void:
	var left_idx: int = self._left_child(index)
	var right_idx: int = self._right_child(index)
	var smallest: int = index
	var size: int = self.data.size()

	if left_idx < size and self.dict[self.data[left_idx]] < self.dict[self.data[smallest]]:
		smallest = left_idx
	
	if right_idx < size and self.dict[self.data[right_idx]] < self.dict[self.data[smallest]]:
		smallest = right_idx

	if smallest != index:
		self._swap(index, smallest)
		self._down_heap(smallest)
