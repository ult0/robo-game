extends Resource
class_name UnitResource

@export var name: String = "Unit"
@export var sprite_path: String = "res://assets/sprites/Puny-Characters/Soldier-Blue.png"
@export var max_health: int = 100
@export var health: int = max_health
@export var move_speed: int = 5
@export var attack: int = 20
@export var defense: int = 10
@export var attack_range: int = 1
	

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		health = 0

func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		health = max_health

func is_alive() -> bool:
	return health > 0

func is_dead() -> bool:
	return health <= 0

func is_selected() -> bool:
	return true

func is_moving() -> bool:
	return false

func is_attacking() -> bool:
	return false




