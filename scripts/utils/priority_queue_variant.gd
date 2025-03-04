class_name PriorityQueueVar extends Resource

"""
Priority Queue. Min heap priority queue that can take a Vector2 and its
corresponding cost and then always return the Vector2 in it with
the lowest cost value.
Based on: https://en.wikipedia.org/wiki/Binary_heap
"""
var data: Array[Variant] = []

func insert(element: Variant, cost: float) -> void:
	# Add the element to the bottom level of the heap at the leftmost open space
	self.data.push_back({ "element": element, "cost": cost})
	var new_element_index: int = self.data.size() - 1
	self._up_heap(new_element_index)

func extract() -> Variant:
	if self.is_empty():
		return null
	var result: Variant = self.data.pop_front()
	# If the tree is not empty, replace the root of the heap with the last
	# element on the last level.
	if not self.is_empty():
		self.data.push_front(self.data.pop_back())
		self._down_heap(0)
	return result["element"]

func is_empty() -> bool:
	return self.data.is_empty()

func _get_parent(index: int) -> int:
	# warning-ignore:integer_division
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
	# Compare the added element with its parent; if they are in the correct order, stop.
	var parent_idx = self._get_parent(index)
	if self.data[index]["cost"] >= self.data[parent_idx]["cost"]:
		return
	self._swap(index, parent_idx)
	self._up_heap(parent_idx)

func _down_heap(index: int) -> void:
	var left_idx: int = self._left_child(index)
	var right_idx: int = self._right_child(index)
	var smallest: int = index
	var size: int = self.data.size()

	if right_idx < size and self.data[right_idx]["cost"] < self.data[smallest]["cost"]:
		smallest = right_idx

	if left_idx < size and self.data[left_idx]["cost"] < self.data[smallest]["cost"]:
		smallest = left_idx

	if smallest != index:
		self._swap(index, smallest)
		self._down_heap(smallest)
