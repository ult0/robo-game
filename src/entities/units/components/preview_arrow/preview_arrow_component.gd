extends UnitComponent
class_name PreviewArrowComponent

@export var preview_arrow: PreviewArrow

func setup(_unit) -> void:
	if _unit is Unit:
		unit = _unit
		unit.selected.connect(func (_selected: bool) -> void: update())
		unit.moving.connect(func (_moving: bool) -> void: update())
	else:
		printerr("PreviewArrow can only be setup with a Unit instance.")
		return

func update() -> void:
	preview_arrow.draw(unit)
