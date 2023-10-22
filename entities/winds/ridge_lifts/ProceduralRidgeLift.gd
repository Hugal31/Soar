@tool
class_name ProceduralRidgeLift
extends Node3D


@export var ridge_lift: RidgeLift:
	set(r):
		if not is_node_ready() or not Engine.is_editor_hint():
			ridge_lift = r
			return

		if ridge_lift != null:
			ridge_lift.changed.disconnect(_on_ridge_lift_changed)
			if ridge_lift.curve != null:
				ridge_lift.curve.changed.disconnect(_on_curve_changed)
		ridge_lift = r
		if ridge_lift != null:
			ridge_lift.changed.connect(_on_ridge_lift_changed)
			if ridge_lift.curve != null:
				ridge_lift.curve.changed.connect(_on_curve_changed)


@export var path: Path3D:
	set(p):
		path = p
		if path != null and ridge_lift != null:
			path.curve = ridge_lift.curve

@export var wind_component: RidgeLiftWindAreaComponent
@export var collision_shape: CollisionShape3D
@export var particles: GPUParticles3D

const curve_texture_resolution := 256

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		if ridge_lift != null and not ridge_lift.changed.is_connected(_on_ridge_lift_changed):
			ridge_lift.changed.connect(_on_ridge_lift_changed)

	if path != null and ridge_lift != null:
		path.curve = ridge_lift.curve

	_on_ridge_lift_changed()


func _on_ridge_lift_changed():
	if path != null and ridge_lift != null:
		path.curve = ridge_lift.curve

	if ridge_lift.curve != null and not ridge_lift.curve.changed.is_connected(_on_curve_changed):
		ridge_lift.curve.changed.connect(_on_curve_changed)

	wind_component.ridge_lift = ridge_lift
	_on_curve_changed()


func _on_curve_changed():
	if ridge_lift.curve == null or ridge_lift.curve.point_count < 2:
		return

	var curve2D := ProceduralRidgeLift.curve3D_to_2D(ridge_lift.curve)

	var curve_aabb := ProceduralRidgeLift._compute_curve2D_aabb(curve2D)
	var size := Vector3(curve_aabb.size.x,
		curve_aabb.size.y + ridge_lift.radius * 2,
		ridge_lift.width)
	var center2D := curve_aabb.get_center()
	var center := Vector3(center2D.x, center2D.y, 0)
	collision_shape.position = center
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = size
	else:
		var box := BoxShape3D.new()
		box.size = size
		collision_shape.shape = box

	if particles != null:
		particles.visibility_aabb = AABB(size * Vector3(0, -0.5, -0.5), size)
		if particles.process_material is ShaderMaterial:
			var material := particles.process_material as ShaderMaterial
			var curve_data := ProceduralRidgeLift._sample_curve_to_image(curve2D, curve_texture_resolution)
			var curve_image := Image.create_from_data(curve_texture_resolution, 1, false, Image.FORMAT_RF, curve_data.to_byte_array())
			var height_texture = material.get_shader_parameter("height_texture")
			if not height_texture is ImageTexture:
				height_texture = ImageTexture.new()
				material.set_shader_parameter("height_texture", height_texture)
			height_texture.set_image(curve_image)
			material.set_shader_parameter("lift_length", size.x)
			material.set_shader_parameter("lift_radius", ridge_lift.radius)
			material.set_shader_parameter("lift_width", ridge_lift.width)
			material.set_shader_parameter("lift_strength", ridge_lift.strength)


## Return a array of the Y value of the texture along its X span
## The curve should be X-monotonic (do not go decreasing in X).
static func _sample_curve_to_image(curve: Curve2D, resolution: int) -> PackedFloat32Array:
	var array := PackedFloat32Array()
	array.resize(resolution)
	var min_x := curve.get_point_position(0).x
	var max_x := curve.get_point_position(curve.point_count - 1).x
	var span_x := max_x - min_x
	array.resize(resolution)
	for i in range(0, resolution):
		# Sample baked is in pixel space, not [0,1] space.
		var t := span_x * float(i) / resolution
		# To be sure I sample each pixel on the texture, I use binary search to get to the right pixel.
		var point := curve.sample_baked(t)
		var t_jump := 0.5 * span_x
		var actual_pixel := roundi(float(resolution) * (point.x - min_x) / span_x)
		while actual_pixel != i:
			if actual_pixel > i:
				t -= t_jump
			else:
				t += t_jump
			point = curve.sample_baked(t)
			actual_pixel = roundi(float(resolution) * (point.x - min_x) / span_x)
			t_jump *= 0.5
			if t_jump < 0.001:
				push_error("Could not sample curve at i=%f" % i)
				return array
		array.set(i, point.y)
	return array


static func curve3D_to_2D(curve3D: Curve3D) -> Curve2D:
	var curve2D := Curve2D.new()
	for point_idx in range(0, curve3D.point_count):
		var point3D := curve3D.get_point_position(point_idx)
		var in3D := curve3D.get_point_in(point_idx)
		var out3D := curve3D.get_point_out(point_idx)
		curve2D.add_point(_project_xy(point3D), _project_xy(in3D), _project_xy(out3D))
	return curve2D


static func _project_xy(v: Vector3) -> Vector2:
	return Vector2(v.x, v.y)

## Compute a Curve2D AABB
static func _compute_curve2D_aabb(curve: Curve2D) -> Rect2:
	var points := curve.get_baked_points()
	var aabb := Rect2(points[0], points[0])
	for point in points:
		aabb = aabb.expand(point)
	return aabb


## Compute a Curve3D AABB
static func _compute_curve3D_aabb(curve: Curve3D) -> AABB:
	var points := curve.get_baked_points()
	var aabb := AABB(points[0], points[0])
	for point in points:
		aabb = aabb.expand(point)
	return aabb
