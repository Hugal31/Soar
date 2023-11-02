class_name RidgeLiftWindAreaComponent
extends WindAreaComponent

@export var ridge_lift: RidgeLift:
	set(r):
		ridge_lift = r
		_precompute()
@export var curve: Curve3D

@onready var parent: Node3D = get_parent()
var squared_half_width := 0.
var squared_radius := 0.


const SAMPLING_RANGE_FACTOR := 1. / 8.
const SAMPLING_T_STOP_THRESHOLD = 1.
const SAMPLING_DISTANCE_STOP_THRESHOLD := 1.


func _ready():
	_precompute()


func _precompute():
	if ridge_lift:
		squared_half_width = sqrt(.5 * ridge_lift.width)
		squared_radius = sqrt(ridge_lift.radius)

func get_wind_at_position(position: Vector3) -> Vector3:
	if ridge_lift == null or curve == null:
		return Vector3()

	var position_in_lift := parent.to_local(position)
	var y_strenght_factor := sqrt(ridge_lift.radius - abs(position_in_lift.y)) / squared_radius;
	var z_strenght_factor := sqrt(0.5 * ridge_lift.width - abs(position_in_lift.z)) / squared_half_width;
	var strength_factor = y_strenght_factor * z_strenght_factor;
	if is_nan(strength_factor):
		return Vector3()

	var x_distance := position_in_lift.x
	var t := get_curve_baked_t_at_x(x_distance)
	var direction := (curve.sample_baked(t + 0.2) - curve.sample_baked(t - 0.2)).normalized()
	return parent.global_transform.basis * direction * strength_factor * ridge_lift.strength


## Return the approx t (in baked space) given the x coordinate 
func get_curve_baked_t_at_x(x: float) -> float:
	var curve_span := absf(curve.get_point_position(curve.point_count - 1).x - curve.get_point_position(0).x)
	var t := x
	var point := curve.sample_baked(t)
	var t_shift := curve_span * SAMPLING_RANGE_FACTOR
	while t_shift > SAMPLING_T_STOP_THRESHOLD \
		and absf(point.x - x) > SAMPLING_DISTANCE_STOP_THRESHOLD:
		if point.x > x:
			t -= t_shift
		else:
			t += t_shift
		t_shift *= 0.5
		point = curve.sample_baked(t)
	if absf(point.x - x) > SAMPLING_DISTANCE_STOP_THRESHOLD:
		push_warning("Failed to interpolate good sampling for x=%.1f, t=%.1f, p_x=%.1f" % [x, t, point.x])
	return t
