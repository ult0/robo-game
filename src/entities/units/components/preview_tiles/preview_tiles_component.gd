extends UnitComponent
class_name PreviewTilesComponent

@export var preview_layer: TileMapLayer

@export var walk_tile_coord: Vector2i = Vector2i(21, 5)
@export var attack_tile_coord: Vector2i = Vector2i(22, 4)
@export var friendly_tile_coord: Vector2i = Vector2i(22, 5)

enum PreviewTile {
	WALK,
	ATTACK,
	FRIENDLY
}
@export var tile_order: Array[PreviewTile]

func setup(_unit) -> void:
	EventBus.unit_action_completed_connect(update)
	if _unit is Unit:
		unit = _unit
		unit.selected.connect(func (_selected: bool) -> void: update())
		unit.moving.connect(func (moving: bool) -> void: if not moving: update())
	else:
		printerr("PreviewTilesComponent can only be setup with a Unit instance.")
		return

func update() -> void:
	if unit and unit.is_selected or (unit is Enemy and unit.force_show_attack_range):
		preview_layer.clear()
		draw_all_tiles()
	else:
		preview_layer.clear()

func draw_all_tiles() -> void:
	for tile_type in tile_order:
		match tile_type:
			PreviewTile.ATTACK:
				draw_tiles(unit.attackable_tiles, attack_tile_coord)
			PreviewTile.WALK:
				draw_tiles(unit.walkable_tiles, walk_tile_coord)
			PreviewTile.FRIENDLY:
				draw_tiles(unit.friendly_tiles, friendly_tile_coord)

func draw_tiles(tiles: Array[Vector2i], tile_coord: Vector2i) -> void:
	for tile in tiles:
		preview_layer.set_cell(tile, 0, tile_coord, 0)
