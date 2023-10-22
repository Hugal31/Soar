class_name RidgeLiftWindAreaComponent
extends WindAreaComponent

@export var ridge_lift: RidgeLift

@onready var parent: Node3D = get_parent()
@onready var squared_half_width := sqrt(.5 * ridge_lift.width)
@onready var squared_radius := sqrt(ridge_lift.radius)


func get_wind_at_position(position: Vector3) -> Vector3:
	if ridge_lift == null or ridge_lift.curve == null:
		return Vector3()

	var position_in_lift := parent.global_transform.inverse() * position
	var y_strenght_factor := sqrt(ridge_lift.radius - abs(position_in_lift.y)) / squared_radius;
	var z_strenght_factor := sqrt(0.5 * ridge_lift.width - abs(position_in_lift.z)) / squared_half_width;
	var strength_factor = y_strenght_factor * z_strenght_factor;
	if is_nan(strength_factor):
		return Vector3()

	var x_distance := position_in_lift.x
	var t := get_curve_baked_t_at_x(x_distance)
	var direction := (ridge_lift.curve.sample_baked(t + 0.2) - ridge_lift.curve.sample_baked(t - 0.2)).normalized()
	return parent.global_transform.basis * direction * strength_factor * ridge_lift.strength


## Return the approx t (in baked space) given the x coordinate 
func get_curve_baked_t_at_x(x: float) -> float:
	var x_begin := ridge_lift.curve.get_point_position(0).x
	var x_end := ridge_lift.curve.get_point_position(ridge_lift.curve.point_count - 1).x
	var x_span := x_end - x_begin
	var t := (x - x_begin) / x_span
	var point := ridge_lift.curve.sample_baked(t)
	var t_shift := 1.
	while t_shift > 0.25 and abs(point.x - x) > 0.5:
		if point.x > x:
			t -= t_shift
		else:
			t += t_shift
		t_shift *= 0.5
	return t
