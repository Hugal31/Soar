extends Node

@export var engine_time_scale := 3.
@export var aircraft: Node3D
@export var score_scale := 20

@onready var _pause_menu := $"../UI/PauseMenu"
@onready var _hud := $"../UI/Aircraft HUD"
@onready var _game_over_menu = $"../UI/GameOverMenu"
@onready var _win_screen = $"../UI/WinScreen"

var _aircraft_start_score: int = 0
var _score: int = 0
var _lock_score := false

var is_in_pause: bool:
	get:
		return _pause_menu.visible


func _ready():
	Engine.time_scale = engine_time_scale
	_hud.set_score(_score)
	_aircraft_start_score = _get_aircraft_current_score()


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func _process(_delta):
	if not _lock_score:
		var aircraft_score := _get_aircraft_current_score()
		if aircraft_score > _score:
			_score = aircraft_score
			_hud.set_score(_score)


func _get_aircraft_current_score() -> int:
	return int(aircraft.global_position.z / score_scale - _aircraft_start_score)


func toggle_pause():
	if is_in_pause:
		unpause()
	else:
		pause()


func game_over():
	_lock_score = true
	_game_over_menu.visible = true


func pause():
	Engine.time_scale = 0
	_pause_menu.visible = true


func unpause():
	Engine.time_scale = engine_time_scale
	_pause_menu.hide()


func restart():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func win():
	var new_score := _score
	var is_best_score := LeaderboardManager.leaderboard.is_new_best_score(new_score)
	_lock_score = true

	LeaderboardManager.leaderboard.add_score(new_score)

	_win_screen.on_new_score(new_score, is_best_score)

	var win_timer := Timer.new()
	win_timer.one_shot = true
	add_child(win_timer)
	win_timer.start(2)
	await win_timer.timeout
	_win_screen.visible = true
	win_timer.queue_free()


func _on_quit():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
