class_name FuelIndicator
extends MarginContainer

@onready var green: Control = $Green
@onready var orange: Control = $Orange
@onready var red: Control = $Red


func set_fuel(level: int):
	green.visible = level >= 3
	orange.visible = level >= 2
	red.visible = level >= 1
