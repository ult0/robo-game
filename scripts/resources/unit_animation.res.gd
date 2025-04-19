extends Resource
class_name UnitAnimationResource

enum State {
	Idle,
	Move,
	Attack,
	Die
}

@export var states: Dictionary[State, PackedVector2Array] = {
	State.Idle: [],
	State.Move: [],
	State.Attack: [],
	State.Die: []
}


