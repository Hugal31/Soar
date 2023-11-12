extends Node

signal changed

@export var wind_direction: Vector3 = Vector3(1, 0, 0):
	set(d):
		wind_direction = d.normalized()
		RenderingServer.global_shader_parameter_set("wind_direction", wind_direction)
		emit_signal("changed")

@export var wind_strength: float = 10.0:
	set(s):
		wind_strength = s
		RenderingServer.global_shader_parameter_set("wind_strength", wind_strength)
		emit_signal("changed")

@export var wind_height_falloff: float = 200:
	set(f):
		wind_height_falloff = f
		RenderingServer.global_shader_parameter_set("wind_height_falloff", wind_height_falloff)
		emit_signal("changed")


func _ready():
	RenderingServer.global_shader_parameter_set("wind_direction", wind_direction)
	RenderingServer.global_shader_parameter_set("wind_strength", wind_strength)
	RenderingServer.global_shader_parameter_set("wind_height_falloff", wind_height_falloff)
