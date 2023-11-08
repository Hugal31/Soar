extends HSlider

@export var channel: StringName

@onready var channel_index := AudioServer.get_bus_index(channel)

const LOGNAME := "VolumeSlider"


func _ready():
	value = db_to_linear(AudioServer.get_bus_volume_db(channel_index))
	value_changed.connect(_on_value_changed)


func _on_value_changed(new_value: float):
	var db_value := linear_to_db(new_value)
	Logger.debug("Set %s volume to %.1f dB" % [channel, db_value], LOGNAME)
	AudioServer.set_bus_volume_db(channel_index, db_value)
