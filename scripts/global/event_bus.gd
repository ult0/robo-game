extends Node

@warning_ignore_start("unused_signal")

signal update_player_units(units: Array[Unit])
signal update_enemy_units(units: Array[Unit])

signal unit_selected(unit: Unit)
signal enemy_selected(enemy: Unit)

