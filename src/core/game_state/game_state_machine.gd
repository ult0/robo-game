class_name GameStateMachine
extends Node2D

enum GameState {
	PLAYER_TURN,
	PLAYER_ACTION,
	TARGETING,
	ENEMY_TURN
}
var current_state: GameState = GameState.PLAYER_TURN
var selected_player: Player
var selected_enemy: Enemy
@onready var unitManager: UnitManager = %UnitManager

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
						set_state(GameState.TARGETING)
					# SELECT ENEMY
					elif selected_unit is Enemy:
						selected_enemy = selected_unit
			
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

		GameState.TARGETING:
			# CONFIRM
			if event.is_action_pressed('left-click'):
				# SWITCH PLAYER
				if unitManager.is_player_at_coord(mouse_coord):
					selected_player = unitManager.select_player_at_coord(mouse_coord)
					set_state(GameState.TARGETING)
				# ENEMY
				elif unitManager.is_enemy_at_coord(mouse_coord):
					var clicked_enemy = unitManager.get_enemy_at_coord(mouse_coord)
					# SELECT ENEMY
					if not selected_enemy or selected_enemy != clicked_enemy:
						selected_enemy = unitManager.select_enemy_at_coord(mouse_coord)
					# ATTACK ENEMY
					elif selected_player \
					and selected_enemy == clicked_enemy \
					and selected_player.is_attackable(clicked_enemy.tile_coord):
						set_state(GameState.PLAYER_ACTION)
						await unitManager.resolve_combat(selected_player, selected_enemy)
						set_state(GameState.TARGETING)
				# TILE
				elif Level.instance.tile_contains_navtile(mouse_coord):
					# MOVE UNIT
					if unitManager.is_player_selected():
						set_state(GameState.PLAYER_ACTION)
						await unitManager.move_player_to_coord(mouse_coord)
						set_state(GameState.TARGETING)
			
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
					set_state(GameState.PLAYER_TURN)

		GameState.PLAYER_ACTION:
			# CONFIRM
			if event.is_action_pressed('left-click'):
				pass
			# CANCEL
			elif event.is_action_pressed('right-click'):
				# TODO: Maybe add undo here?
				pass

		GameState.ENEMY_TURN:
			pass

func handle_key_input(event: InputEventKey):
	match current_state:
		GameState.PLAYER_TURN, GameState.TARGETING:
			# F
			if event.is_pressed() and event.keycode == KEY_F:
				# TOGGLE ALL ENEMY ATTACK RANGES
				if unitManager.enemy_group.force_show_attack_range:
					unitManager.enemy_group.set_force_show_attack_range(false)
				else:
					unitManager.enemy_group.set_force_show_attack_range(true)

func set_state(new_state: GameState):
	_exit_state(current_state)
	current_state = new_state
	_enter_state(new_state)

func _enter_state(state: GameState):
	match state:
		GameState.PLAYER_TURN:
			print("Entered PLAYER_TURN")
		GameState.TARGETING:
			print("Entered TARGETING")
		GameState.PLAYER_ACTION:
			print("Entered PLAYER_ACTION")
		GameState.ENEMY_TURN:
			print("Entered ENEMY_TURN")
		_:
			print("Entered unknown state: ", state)

func _exit_state(state: GameState):
	match state:
		GameState.PLAYER_TURN:
			print("Exited PLAYER_TURN")
		GameState.TARGETING:
			print("Exited TARGETING")
		GameState.PLAYER_ACTION:
			print("Exited PLAYER_ACTION")
		GameState.ENEMY_TURN:
			print("Exited ENEMY_TURN")
		_:
			print("Exited unknown state: ", state)
