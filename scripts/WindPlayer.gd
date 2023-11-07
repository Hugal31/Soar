extends AudioStreamPlayer

@export var aircraft: Aircraft


func _ready():
	# Only start to play after the first frame is processed
	call_deferred("play")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var velocity_weight := (
		(aircraft.horizontal_speed - aircraft.slow_speed.horizontal_speed)
		/ (aircraft.fast_speed.horizontal_speed - aircraft.slow_speed.horizontal_speed)
	)
	volume_db = lerpf(-13, 0, velocity_weight)
	pitch_scale = lerpf(0.8, 1.7, velocity_weight)
