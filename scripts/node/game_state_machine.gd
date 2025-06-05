class_name GameStateMachine
extends Node2D

enum GameState {
	PLAYER_TURN,
	PLAYER_SELECTED,
	ENEMY_SELECTED,
	TARGETING,
	ENEMY_TURN
}
var current_state: GameState = GameState.PLAYER_TURN
var selected_player: Player
var selected_enemy: Enemy
@onready var unitManager: UnitManager =  %UnitManager

func _ready() -> void:
	set_state(GameState.PLAYER_TURN)

func handle_mouse_button_input(event: InputEventMouseButton) -> void:
	var mouse_coord: Vector2i = TileMapUtils.get_tile_coord(get_global_mouse_position())
	match current_state:
		GameState.PLAYER_TURN:
			# CONFIRM
			if event.is_action_pressed('left-click'):
				# UNIT
				if unitManager.is_unit_at_coord(mouse_coord):
					var selected_unit = unitManager.select_unit_at_coord(mouse_coord)
					# SELECT PLAYER
					if selected_unit is Player:
						selected_player = selected_unit
					# SELECT ENEMY
					elif selected_unit is Enemy:
						selected_enemy = selected_unit
				# TILE
				elif Level.instance.tile_contains_navtile(mouse_coord):
					# MOVE UNIT
					if unitManager.is_player_selected():
						unitManager.move_player_to_coord(mouse_coord)
			
			# CANCEL
			elif event.is_action_pressed('right-click'):
				# UNIT
				if unitManager.is_unit_at_coord(mouse_coord):
					var unselected_unit = unitManager.unselect_unit_at_coord(mouse_coord)
					# UNSELECT PLAYER
					if unselected_unit is Player:
						selected_player = null
					# UNSELECT ENEMY
					elif unselected_unit is Enemy:
						selected_enemy = null
				# ANYWHERE
				else:
					# UNSELECT ALL
					if unitManager.is_player_selected():
						unitManager.unselect_current_selected_player()
					if unitManager.is_enemy_selected():
						unitManager.unselect_current_selected_enemy()
		GameState.ENEMY_TURN:
			print("ENEMY_TURN")

func handle_key_input(event: InputEventKey):
	match current_state:
		GameState.PLAYER_TURN:
			# F
			if event.is_pressed() and event.keycode == KEY_F:
				# SHOW ALL ENEMY RANGE
				if unitManager.enemy_group.current_units:
					pass

func set_state(new_state: GameState):
	if current_state == new_state:
		return
	else:
		_exit_state(current_state)
		current_state = new_state
		_enter_state(new_state)

func _enter_state(state: GameState):
	match state:
		GameState.PLAYER_TURN:
			print("Entered PLAYER_TURN")
		GameState.PLAYER_SELECTED:
			print("Entered PLAYER_SELECTED")
		GameState.ENEMY_SELECTED:
			print("Entered ENEMY_SELECTED")
		GameState.ENEMY_TURN:
			print("Entered ENEMY_TURN")

func _exit_state(state: GameState):
	match state:
		GameState.PLAYER_TURN:
			print("Exited PLAYER_TURN")
		GameState.PLAYER_SELECTED:
			print("Exited PLAYER_SELECTED")
		GameState.ENEMY_SELECTED:
			print("Exited ENEMY_SELECTED")
		GameState.ENEMY_TURN:
			print("Exited ENEMY_TURN")
