extends Node2D
class_name UnitManager

var player_group: UnitGroup
var enemy_group: UnitGroup
var tile_selector_coord: Vector2i

func _ready() -> void:
	for child in get_children():
		if child is UnitGroup:
			var unit_group: UnitGroup = child
			if unit_group.type == UnitGroup.UnitType.Player:
				player_group = unit_group
				unit_group.unit_selected.connect(on_player_selected)
			elif unit_group.type == UnitGroup.UnitType.Enemy:
				enemy_group = unit_group
				unit_group.unit_selected.connect(on_enemy_selected)
			else:
				printerr("UnitManager: Child is not a UnitGroup or has an invalid type: " + child.name)
	EventBus.tile_selector_coord_changed.connect(func (coord: Vector2i): tile_selector_coord = coord)
	print("Player units: ", player_group.current_units)
	print("Enemy units: ", enemy_group.current_units)

func on_player_selected(unit: Unit) -> void:
	EventBus.player_selected.emit(unit)

func on_enemy_selected(unit: Unit) -> void:
	EventBus.enemy_selected.emit(unit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left-click"):
		if player_group.selected_unit and player_group.selected_unit.walkable_tiles.has(tile_selector_coord):
			player_group.selected_unit.move_to(tile_selector_coord)
	elif event.is_action_pressed("right-click"):
		if player_group.selected_unit:
			player_group.selected_unit.unselect()
		elif enemy_group.selected_unit:
			enemy_group.selected_unit.unselect()
