class_name WindSquareAreaComponent
extends WindAreaComponent

const HEIGHT_FALLOFF := 500.

@export var box_shape: BoxShape3D
@export var height_map: Image

@onready var parent: Node3D = get_parent()
@onready var _height_map_scale: float = 1000.  # TODO Sync with shader globals


func get_wind_at_position(position: Vector3) -> Vector3:
	var wind_direction := WindManager.wind_direction
	var wind_strength := WindManager.wind_strength
	if height_map != null:
		var p0 := position
		var p1 := p0 + wind_direction * wind_strength
		var local_p0 := _to_box_local(p0)
		var local_p1 := _to_box_local(p1)
		var height0 := (
			_height_map_scale * _linear_sample_r(height_map, Vector2(local_p0.x, local_p0.z))
		)
		var height1 := (
			_height_map_scale * _linear_sample_r(height_map, Vector2(local_p1.x, local_p1.z))
		)
		var new_p0 := p0 + Vector3.UP * height0
		var new_p1 := p1 + Vector3.UP * height1
		var new_wind_direction := ((new_p1 - new_p0) / wind_strength).normalized()
		# Falloff based on height distance
		var height_to_ground := position.y - height0
		var weight := 1. - clampf(height_to_ground / WindManager.wind_height_falloff, 0, 1)
		wind_direction = wind_direction.lerp(new_wind_direction, weight).normalized()
	return wind_direction * wind_strength


# Return p in local box coordinates, between 0 and 1
func _to_box_local(p: Vector3) -> Vector3:
	var local_p := parent.to_local(p)
	var box_p := (local_p + box_shape.size / 2.) / box_shape.size
	return box_p


## Given an image and texture coordinates between 0 and 1,
## return the linearly sampled red value between 0 and 1.
static func _linear_sample_r(image: Image, tex_coor: Vector2) -> float:
	var height := image.get_height()
	var width := image.get_width()
	var p0 := Vector2i(
		clampi(tex_coor.x * width, 0, width - 1), clampi(tex_coor.y * height, 0, height - 1)
	)
	var p1 := Vector2i(min(p0.x + 1, width - 1), min(p0.y + 1, height - 1))

	var frac_x := tex_coor.x * width - p0.x
	var frac_y := tex_coor.y * height - p0.y

	var color00 := image.get_pixel(p0.x, p0.y).r
	var color10 := image.get_pixel(p1.x, p0.y).r
	var color01 := image.get_pixel(p0.x, p1.y).r
	var color11 := image.get_pixel(p1.x, p1.y).r

	var color_top := lerpf(color00, color10, frac_x)
	var color_bottom := lerpf(color01, color11, frac_x)
	var final_color := lerpf(color_top, color_bottom, frac_y)
	return final_color
