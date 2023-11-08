extends Node3D

@export var engine_time_scale := 2.

@onready var pause_menu := $UI/PauseMenu

var is_in_pause: bool:
	get:
		return pause_menu.visible


func _ready():
	Engine.time_scale = engine_time_scale


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if is_in_pause:
			unpause()
		else:
			pause()


func pause():
	Engine.time_scale = 0
	pause_menu.visible = true


func unpause():
	Engine.time_scale = engine_time_scale
	pause_menu.hide()


func _on_quit():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
