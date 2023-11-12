class_name ProceduralWindSquareArea
extends Node3D

@export var height_map: Image:
	set(h):
		height_map = h
		if is_node_ready():
			_on_height_map_changed()
@export var shape: BoxShape3D:
	set(s):
		shape = s
		if is_node_ready():
			_on_shape_changed()
@export var particle_density := 0.1

@onready var _particles: GPUParticles3D = $GPUParticles3D
@onready var _wind_area_collision: CollisionShape3D = $WindArea/CollisionShape3D
@onready var _wind_area_component: WindAreaComponent = $WindArea/WindSquareAreaComponent


func _ready():
	_particles.process_material = _particles.process_material.duplicate(true)
	_on_height_map_changed()
	_on_shape_changed()


func _on_shape_changed():
	_particles.visibility_aabb = AABB(-shape.size / 2, shape.size)
	_particles.amount = shape.size.length() * particle_density
	var material := _particles.process_material as ShaderMaterial
	material.set_shader_parameter("box_size", shape.size)

	_wind_area_component.box_shape = shape
	_wind_area_collision.shape = shape


func _on_height_map_changed():
	var material := _particles.process_material as ShaderMaterial
	material.set_shader_parameter("height_map", ImageTexture.create_from_image(height_map))
	_wind_area_component.height_map = height_map
