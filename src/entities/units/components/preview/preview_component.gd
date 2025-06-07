extends UnitComponent
class_name PreviewComponent

@onready var preview_layer: TileMapLayer = $PreviewLayer
@onready var preview_arrow: PreviewArrow = $PreviewArrow

@export var walk_tile_coord: Vector2i = Vector2i(21, 5)
@export var attack_tile_coord: Vector2i = Vector2i(22, 4)
@export var friendly_tile_coord: Vector2i = Vector2i(22, 5)

enum PreviewTile {
	WALK,
	ATTACK,
	FRIENDLY
}
@export var tile_order: Array[PreviewTile]

var selector_coord: Vector2i

func setup(_unit) -> void:
	if _unit is Unit:
		unit = _unit
		unit.selected.connect(func (_selected: bool) -> void: update())
		unit.moving.connect(func (moving: bool) -> void: if not moving: update())
		preview_arrow.unit = unit
	else:
		printerr("PreviewComponent can only be setup with a Unit instance.")
		return
	EventBus.selector_coord_changed_connect(on_tile_selector_entered)

func on_tile_selector_entered(coord: Vector2i) -> void:
	selector_coord = coord
	preview_arrow.draw(selector_coord)

func update() -> void:
	if unit and unit.is_selected or (unit is Enemy and unit.force_show_attack_range):
		preview_layer.clear()
		draw_all_tiles()
		preview_layer.enabled = true
		preview_arrow.draw(selector_coord)
	else:
		preview_layer.clear()
		preview_layer.enabled = false
		preview_arrow.draw(selector_coord)

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
