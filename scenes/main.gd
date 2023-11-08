extends Node3D

@export var engine_time_scale := 2.
@export var aircraft: Node3D
@export var score_scale := 20

@onready var _pause_menu := $UI/PauseMenu
@onready var _hud := $"UI/Aircraft HUD"

var _aircraft_start_score: int = 0
var _score: int = 0

var is_in_pause: bool:
	get:
		return _pause_menu.visible


func _ready():
	Engine.time_scale = engine_time_scale
	_hud.set_score(_score)
	_aircraft_start_score = _get_aircraft_current_score()


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

	var aircraft_score := _get_aircraft_current_score()
	if aircraft_score > _score:
		_score = aircraft_score
		_hud.set_score(_score)


func _get_aircraft_current_score() -> int:
	return aircraft.global_position.z / score_scale - _aircraft_start_score


func toggle_pause():
	if is_in_pause:
		unpause()
	else:
		pause()


func pause():
	Engine.time_scale = 0
	_pause_menu.visible = true


func unpause():
	Engine.time_scale = engine_time_scale
	_pause_menu.hide()


func _on_quit():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_glider_fuel_level_changed(fuel: int):
	_hud.set_fuel(fuel)
