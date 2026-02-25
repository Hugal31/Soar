extends Menu

@export var new_score_label: Control
@export var new_best_score_label: Control
@export var score_value_label: Label


func enter():
	$VBoxContainer/VBoxContainer/Restart.grab_focus()


func on_new_score(score: int, is_best: bool):
	score_value_label.text = str(score)
	new_score_label.visible = not is_best
	new_best_score_label.visible = is_best
