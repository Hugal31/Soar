extends RichTextLabel

@export var file_path: String


# Called when the node enters the scene tree for the first time.
func _ready():
	var content := FileAccess.get_file_as_string(file_path)
	text = content

	meta_clicked.connect(_on_meta_clicked)


func _on_meta_clicked(meta):
	OS.shell_open(meta)
