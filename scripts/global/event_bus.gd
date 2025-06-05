extends Node

@warning_ignore_start("unused_signal")
signal _selector_coord_changed(coord: Vector2i)
func selector_coord_changed_connect(c: Callable):
	_selector_coord_changed.connect(c)
func selector_coord_changed_emit(coord: Vector2i):
	_selector_coord_changed.emit(coord)

signal _unit_spawned(unit: Unit)
func unit_spawned_connect(c: Callable):
	_unit_spawned.connect(c)
func unit_spawned_emit(unit: Unit):
	_unit_spawned.emit(unit)

signal _player_selected(player: Player)
func player_selected_connect(c: Callable):
	_player_selected.connect(c)
func player_selected_emit(player: Player):
	_player_selected.emit(player)

signal _enemy_selected(enemy: Enemy)
func enemy_selected_connect(c: Callable):
	_enemy_selected.connect(c)
func enemy_selected_emit(enemy: Enemy):
	_enemy_selected.emit(enemy)
