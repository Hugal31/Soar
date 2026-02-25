extends Menu

@export var game_scene: PackedScene
@export var credits_scene: PackedScene

@onready var main_menu = $Menu
@onready var tutorials = $Tutorial
@onready var leaderboard = $Leaderboard
@onready var settings = $Settings
@onready var credits = $Credits
@onready var back_button = $BackButton

var _previous_focus: Button = null


func enter():
	$Menu/Start.grab_focus()


func _on_start_pressed():
	RandomNumberGeneratorManager.set_random()
	_start_game()


func _on_task_of_the_day_pressed():
	RandomNumberGeneratorManager.use_day_seed()
	_start_game()


func _start_game():
	get_tree().change_scene_to_packed(game_scene)


func _show_sub_menu(sub_menu: Control):
	_previous_focus = get_viewport().gui_get_focus_owner()
	main_menu.hide()
	sub_menu.visible = true
	back_button.visible = true


func _on_settings_pressed():
	_show_sub_menu(settings)
	settings.enter()


func _on_tutorial_pressed():
	_show_sub_menu(tutorials)
	back_button.grab_focus()


func _on_credits_pressed():
	_show_sub_menu(credits)
	back_button.grab_focus()


func _on_back_button_pressed():
	main_menu.visible = true
	back_button.hide()
	settings.hide()
	leaderboard.hide()
	tutorials.hide()
	credits.hide()
	if _previous_focus:
		_previous_focus.grab_focus()
	else:
		$Menu/Start.grab_focus()


func _on_leaderboard_pressed():
	_show_sub_menu(leaderboard)
	back_button.grab_focus()
