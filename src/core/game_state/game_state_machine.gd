class_name GameStateMachine
extends Node2D

enum GameState {
	PLAYER_TURN_START,
	PLAYER_TURN,
	PLAYER_TURN_END,
	PLAYER_SELECTED,
	PLAYER_ACTION,
	ENEMY_TURN_START,
	ENEMY_TURN,
	ENEMY_TURN_END,
	GAME_OVER,
	LEVEL_COMPLETE
}
var turn: int = 1
var current_state: GameState
var currently_interactable: bool:
	get:
		return current_state == GameState.PLAYER_TURN or current_state == GameState.PLAYER_SELECTED

var command_queue: Array[Callable] = []
@onready var unitManager: UnitManager = %UnitManager
@onready var camera: Camera = %Camera

func _ready() -> void:
	set_state(GameState.PLAYER_TURN_START)

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
					if unitManager.selected_enemy != clicked_enemy:
						unitManager.select_enemy_at_coord(mouse_coord)
					# ATTACK SELECTED ENEMY
					else:
						command_queue.append(unitManager.try_combat.bind(unitManager.selected_player, clicked_enemy))
						set_state(GameState.PLAYER_ACTION)
				# TILE
				elif Level.instance.tile_contains_navtile(mouse_coord):
					# MOVE UNIT
					if unitManager.is_player_selected():
						command_queue.append(unitManager.move_player_to_coord.bind(mouse_coord))
						set_state(GameState.PLAYER_ACTION)
			
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
			if event.is_action_pressed('left-click', true):
				var move_tween = unitManager.selected_player.move_tween
				if move_tween and move_tween.is_valid() and move_tween.is_running():
					move_tween.set_speed_scale(10)

		GameState.ENEMY_TURN:
			if event.is_action_pressed('left-click', true):
				for enemy in unitManager.enemy_group.current_units:
					if enemy.move_tween and enemy.move_tween.is_valid() and enemy.move_tween.is_running():
						enemy.move_tween.set_speed_scale(10)

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
			# E
			if event.is_pressed() and event.keycode == KEY_E:
				# END PLAYER TURN
				set_state(GameState.PLAYER_TURN_END)

func set_state(new_state: GameState):
	print("Exiting state: ", GameState.keys()[current_state])
	_exit_state(current_state)
	current_state = new_state
	print("Entering state: ", GameState.keys()[new_state])
	_enter_state(new_state)

func _enter_state(state: GameState):
	if state not in GameState.values():
		assert(false, "Entered unknown state: " + str(GameState.keys()[state]))
	match state:
		GameState.PLAYER_TURN_START:
			# Show player turn UI
			# Setup players
			# Start player turn
			set_state(GameState.PLAYER_TURN)
		GameState.PLAYER_ACTION:
			# Execute Actions
			for i: int in range(command_queue.size()):
				print("Executing Command: ", command_queue[i])
				var command = command_queue.pop_front()
				await command.call()
				# Update everything after action is completed
				EventBus.update_emit()

			# Check if all enemies are dead to end level
			if unitManager.are_all_enemies_dead():
				set_state(GameState.LEVEL_COMPLETE)
			# Check if all players are dead for game over
			elif unitManager.are_all_players_dead():
				set_state(GameState.GAME_OVER)
			# Check if player can continue turn
			elif can_player_turn_continue():
				set_state(GameState.PLAYER_SELECTED)
			# Check if turn should be force ended
			else:
				set_state(GameState.PLAYER_TURN_END)
		GameState.PLAYER_TURN_END:
			unitManager.unselect_all_current_selected_units()
			set_state(GameState.ENEMY_TURN_START)
		GameState.ENEMY_TURN_START:
			# Show enemy turn UI
			# Start Enemy Turn
			set_state(GameState.ENEMY_TURN)
		GameState.ENEMY_TURN:
			for enemy in unitManager.enemy_group.current_units:
				if unitManager.are_all_players_dead():
					break
				# Focus on enemy
				await camera.focus(enemy.global_position)
				# Execute enemy turn
				print(enemy, " executing turn...")
				await unitManager.handle_enemy_turn(enemy)
				EventBus.update_emit()
			# End enemy turn
			set_state(GameState.ENEMY_TURN_END)
		GameState.ENEMY_TURN_END:
			# Check if all enemies are dead to end level
			if unitManager.are_all_enemies_dead():
				set_state(GameState.LEVEL_COMPLETE)
			# Check if all players are dead for game over
			elif unitManager.are_all_players_dead():
				set_state(GameState.GAME_OVER)
			else:
				# Increment Turn Count
				turn += 1
				# TODO: After updating game states move player turn start logic to player turn end
				EventBus.player_turn_start_emit(turn)
				EventBus.enemy_turn_end_emit(turn)
				print("TURN ", turn)
				# Set state to player turn
				set_state(GameState.PLAYER_TURN_START)
		GameState.GAME_OVER:
			unitManager.unselect_all_current_selected_units()
			EventBus.game_over_emit()
			print("GAME OVER")
		GameState.LEVEL_COMPLETE:
			unitManager.unselect_all_current_selected_units()
			EventBus.level_completed_emit()
			print("LEVEL COMPLETE")

func _exit_state(state: GameState):
	if state not in GameState.values():
		assert(false, "Exited unknown state: " + str(GameState.keys()[state]))
	match state:
		_:
			pass
	# After every state change, update
	EventBus.update_emit()

func can_player_turn_continue() -> bool:
	# Check if player units have no more options
	var can_continue: bool = false
	for unit in unitManager.player_group.current_units:
		if unit.unit_resource.movement > 0:
			can_continue = true
	return can_continue
