extends Node

const LOGNAME := "WindRandomizer"

## Max angle change in degrees.
@export_range(10, 180) var max_angle_change := 45.0
## Max ratio to change the wind strenght: 0.5 means the wind won't change more than 50%
@export var max_strength_change := 0.5
@export var strength_mean := 10.
@export var strength_stddev := 10.
@export var duration_mean := 120.
@export var duration_stddev := 20.
@export var transition_duration_mean := 30.
@export var transition_duration_stddev := 20.

var wind_angle: float = 0:
	set(a):
		wind_angle = a
		WindManager.wind_direction = Vector3(0, 0, 1).rotated(Vector3.UP, wind_angle)

var timer: Timer
@onready var rng := RandomNumberGeneratorManager.get_sub_rng()


func set_wind_angle(angle: float):
	WindManager.wind_direction = Vector3(1, 0, 0).rotated(Vector3.UP, angle)


func _ready():
	Logger.add_module(LOGNAME)
	timer = Timer.new()
	timer.autostart = false
	timer.timeout.connect(self._on_timeout)
	add_child(timer)
	wind_angle = rng.randf_range(-PI, PI)

	randomize_wind(true)


func randomize_wind(instant: bool = false):
	var max_rad_change = deg_to_rad(max_angle_change)
	var new_angle := rng.randf_range(-max_rad_change, max_rad_change)
	var new_strength := clampf(
		absf(rng.randfn(strength_mean, strength_stddev)),
		WindManager.wind_strength - WindManager.wind_strength * max_strength_change,
		WindManager.wind_strength + WindManager.wind_strength * max_strength_change
	)
	var duration := maxf(10., rng.randfn(duration_mean, duration_stddev))
	if instant:
		wind_angle += new_angle
		WindManager.wind_strength = new_strength
	else:
		var transition_duration := minf(
			rng.randfn(transition_duration_mean, transition_duration_stddev), duration
		)
		var tween := create_tween()
		tween.tween_property(self, "wind_angle", new_angle, transition_duration).as_relative()
		tween.tween_property(WindManager, "wind_strength", new_strength, transition_duration)
	timer.start(duration)
	while new_angle < 0:
		new_angle += PI
	Logger.info(
		"Set wind %03d %02d for %.1f seconds" % [rad_to_deg(new_angle), new_strength, duration],
		LOGNAME
	)


func _on_timeout():
	randomize_wind()
