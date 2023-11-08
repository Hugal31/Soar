extends RichTextLabel

@export var file_path: String


# Called when the node enters the scene tree for the first time.
func _ready():
	var content := FileAccess.get_file_as_string(file_path)
	text = content
