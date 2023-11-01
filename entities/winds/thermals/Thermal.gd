@tool
extends Resource
class_name Thermal
## Cylindrical vertical thermal

## The radius of the thermal.
@export_range(20, 200) var radius: float = 75.0:
	set(r):
		radius = r
		emit_signal("changed")

## The strength of the wind.
@export_range(1, 50) var strength: float = 7.0:
	set(s):
		strength = s
		emit_signal("changed")
