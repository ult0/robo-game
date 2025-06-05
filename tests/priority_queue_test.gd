extends "res://addons/gut/test.gd"

var PriorityQueue = preload("res://scripts/utils/priority_queue/priority_queue.gd")

func test_extract_returns_items_in_increasing_cost_order():
    var pq = PriorityQueue.new()
    pq.insert("a", 5)
    pq.insert("b", 1)
    pq.insert("c", 3)
    pq.insert("d", 2)

    var results := []
    while not pq.is_empty():
        results.append(pq.extract())

    assert_eq(results, ["b", "d", "c", "a"])
