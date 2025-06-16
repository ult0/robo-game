class_name GameStateMachine
extends Node2D

enum GameState {
	PLAYER_TURN,
	PLAYER_ACTION,
	PLAYER_SELECTED,
	ENEMY_TURN
}
var turn: int = 1
var current_state: GameState = GameState.PLAYER_TURN
@onready var unitManager: UnitManager = %UnitManager

func _ready() -> void:
	set_state(GameState.PLAYER_TURN)

func handle_mouse_button_input(event: InputEventMouseButton) -> void:
	var mouse_coord: Vector2i = TileMapUtils.get_tile_coord(get_global_mouse_position())
	match current_state:
		GameState.PLAYER_TURN:
			# CONFIRM
			if event.is_action_pressed('left-click'):
				# SELECT PLAYER
				if unitManager.is_player_at_coord(mouse_coord):
					unitManager.select_player_at_coord(mouse_coord)
					set_state(GameState.PLAYER_SELECTED)
				# SELECT ENEMY
				elif unitManager.is_enemy_at_coord(mouse_coord):
					unitManager.select_enemy_at_coord(mouse_coord)
			
			# CANCEL
			elif event.is_action_pressed('right-click'):
				# UNSELECT ENEMY
				if unitManager.is_enemy_at_coord(mouse_coord):
					unitManager.unselect_enemy_at_coord(mouse_coord)
				# ANYWHERE ELSE
				else:
					# UNSELECT ALL
					if unitManager.is_player_selected():
						unitManager.unselect_current_selected_player()
					if unitManager.is_enemy_selected():
						unitManager.unselect_current_selected_enemy()

		GameState.PLAYER_SELECTED:
			# CONFIRM
			if event.is_action_pressed('left-click'):
				# SWITCH PLAYER
				if unitManager.is_player_at_coord(mouse_coord):
					unitManager.select_player_at_coord(mouse_coord)
					set_state(GameState.PLAYER_SELECTED)
				# ENEMY
				elif unitManager.is_enemy_at_coord(mouse_coord):
					var clicked_enemy = unitManager.get_enemy_at_coord(mouse_coord)
					# SELECT ENEMY
					if unitManager.enemy_group.selected_unit != clicked_enemy:
						unitManager.select_enemy_at_coord(mouse_coord)
					# ATTACK SELECTED ENEMY
					else:
						var selected_player = unitManager.player_group.selected_unit
						if selected_player.can_attack_after_moving(clicked_enemy.tile_coord):
							set_state(GameState.PLAYER_ACTION)
							await unitManager.resolve_combat(selected_player, clicked_enemy)
							set_state(GameState.PLAYER_SELECTED)
				# TILE
				elif Level.instance.tile_contains_navtile(mouse_coord):
					# MOVE UNIT
					if unitManager.is_player_selected():
						set_state(GameState.PLAYER_ACTION)
						await unitManager.move_player_to_coord(mouse_coord)
						set_state(GameState.PLAYER_SELECTED)
			
			# CANCEL
			elif event.is_action_pressed('right-click'):
				# UNSELECT PLAYER
				if unitManager.is_player_at_coord(mouse_coord):
					unitManager.unselect_player_at_coord(mouse_coord)
					set_state(GameState.PLAYER_TURN)
				# UNSELECT ENEMY
				elif unitManager.is_enemy_at_coord(mouse_coord):
					unitManager.unselect_enemy_at_coord(mouse_coord)
				# ANYWHERE ELSE
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
		GameState.PLAYER_TURN, GameState.PLAYER_SELECTED:
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
		GameState.PLAYER_SELECTED:
			print("Entered PLAYER_SELECTED")
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
		GameState.PLAYER_SELECTED:
			print("Exited PLAYER_SELECTED")
		GameState.PLAYER_ACTION:
			print("Exited PLAYER_ACTION")
			EventBus.unit_action_completed_emit()
		GameState.ENEMY_TURN:
			print("Exited ENEMY_TURN")
			# Increment Turn Count
			turn += 1
			EventBus.turn_start_emit(turn)
		_:
			print("Exited unknown state: ", state)
