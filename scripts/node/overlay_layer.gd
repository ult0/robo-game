extends TileMapLayer

var selected_player: Player = null
var selected_enemy: Enemy = null
var selected_unit_walkable_tiles: Array[Vector2i] = []
var other_unit_tiles: Array[Vector2i] = []
var selected_unit_attackable_tiles: Array[Vector2i] = []

var walk_tile_coord: Vector2i = Vector2i(21, 5)
var attack_tile_coord: Vector2i = Vector2i(22, 4)
var player_tile_coord: Vector2i = Vector2i(22, 5)

func _ready() -> void:
	EventBus.player_selected.connect(on_selected_player)
	EventBus.enemy_selected.connect(on_selected_enemy)

func draw_tiles(tiles: Array[Vector2i], tile_coord: Vector2i) -> void:
	for tile in tiles:
		set_cell(tile, 0, tile_coord, 0)

func on_selected_player(player: Player) -> void:
	selected_player = player
	if selected_player and !selected_player.moving:
		# Clear any tiles from previous selection
		clear()

		# Order matters, attackable tiles first
		draw_tiles(selected_player.attackable_tiles, attack_tile_coord)
		draw_tiles(selected_player.walkable_tiles, walk_tile_coord)
		draw_tiles(selected_player.tiles_with_players, player_tile_coord)
	else:
		clear()

func on_selected_enemy(enemy: Enemy) -> void:
	selected_enemy = enemy
	if selected_enemy:
		# Clear any tiles from previous selection
		clear()

		# Order matters, attackable tiles first
		draw_tiles(selected_enemy.attackable_tiles, attack_tile_coord)
		#draw_tiles(selected_enemy.walkable_tiles, walk_tile_coord)
		#draw_tiles(selected_enemy.tiles_with_enemies, player_tile_coord)
	else:
		clear()
