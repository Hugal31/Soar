extends Control

# Not a big fan of the "bubble up" thing, or at least with less boilerplate.
signal resume
signal quit

@onready var _buttons := $PauseMenuButtons
@onready var _settings := $Settings
@onready var _back_button := $BackButton


func _on_resume_pressed():
	emit_signal("resume")


func _on_quit_pressed():
	emit_signal("quit")


func _on_settings_pressed():
	_buttons.hide()
	_back_button.visible = true
	_settings.visible = true


func _on_back_button_pressed():
	_buttons.visible = true
	_back_button.hide()
	_settings.hide()
