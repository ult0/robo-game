extends Node

signal _level_completed()
func level_completed_connect(c: Callable):
	_level_completed.connect(c)
func level_completed_emit():
	_level_completed.emit()

signal _game_over()
func game_over_connect(c: Callable):
	_game_over.connect(c)
func game_over_emit():
	_game_over.emit()

signal _player_turn_start(turn_num: int)
func player_turn_start_connect(c: Callable):
	_player_turn_start.connect(c)
func player_turn_start_emit(turn_num: int):
	_player_turn_start.emit(turn_num)

signal _enemy_turn_start(turn_num: int)
func enemy_turn_start_connect(c: Callable):
	_enemy_turn_start.connect(c)
func enemy_turn_start_emit(turn_num: int):
	_enemy_turn_start.emit(turn_num)

signal _unit_action_completed()
func unit_action_completed_connect(c: Callable):
	_unit_action_completed.connect(c)
func unit_action_completed_emit():
	_unit_action_completed.emit()

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
