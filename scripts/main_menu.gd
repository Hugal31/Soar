extends Control

@export var game_scene: PackedScene
@export var credits_scene: PackedScene

@onready var main_menu = $Menu
@onready var credits = $Credits


func _on_start_pressed():
	_start_game()


func _on_task_of_the_day_pressed():
	_start_game()


func _start_game():
	get_tree().change_scene_to_packed(game_scene)


func _on_credits_pressed():
	main_menu.hide()
	credits.visible = true


func _on_credits_back_button_pressed():
	main_menu.visible = true
	credits.hide()
