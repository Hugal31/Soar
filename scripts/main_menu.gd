extends Control

@export var game_scene: PackedScene
@export var credits_scene: PackedScene

@onready var main_menu = $Menu
@onready var tutorials = $Tutorial
@onready var leaderboard = $Leaderboard
@onready var settings = $Settings
@onready var credits = $Credits
@onready var back_button = $BackButton


func _on_start_pressed():
	_start_game()


func _on_task_of_the_day_pressed():
	_start_game()


func _start_game():
	get_tree().change_scene_to_packed(game_scene)


func _show_sub_menu(sub_menu: Control):
	main_menu.hide()
	sub_menu.visible = true
	back_button.visible = true


func _on_settings_pressed():
	_show_sub_menu(settings)


func _on_tutorial_pressed():
	_show_sub_menu(tutorials)


func _on_credits_pressed():
	_show_sub_menu(credits)


func _on_back_button_pressed():
	main_menu.visible = true
	back_button.hide()
	settings.hide()
	leaderboard.hide()
	tutorials.hide()
	credits.hide()


func _on_leaderboard_pressed():
	_show_sub_menu(leaderboard)
