class_name Menu
extends Control


func _ready() -> void:
	if get_parent() == get_tree().root:
		enter.call_deferred()


## Enter in the menu. This should make a button grab the focus.
func enter():
	pass
