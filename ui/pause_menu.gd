extends Menu

# Not a big fan of the "bubble up" thing, or at least with less boilerplate.
signal resume
signal quit

@onready var _buttons := $PauseMenuButtons
@onready var _settings := $Settings
@onready var _back_button := $BackButton


func enter():
	$PauseMenuButtons/Resume.grab_focus()


func _on_resume_pressed():
	resume.emit()


func _on_quit_pressed():
	quit.emit()


func _on_settings_pressed():
	_buttons.hide()
	_back_button.visible = true
	_settings.visible = true


func _on_back_button_pressed():
	_buttons.visible = true
	_back_button.hide()
	_settings.hide()
	$PauseMenuButtons/Settings.grab_focus()
