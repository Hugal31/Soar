@tool
extends Node3D
class_name ProceduralThermal


@export var thermal: Thermal:
	set(t):
		if not is_node_ready():
			thermal = t
			return

		# Check if this is called before or after _ready, if it is called at all.
		if thermal != null:
			thermal.changed.disconnect(self._update_shape)
		thermal = t
		if thermal != null:
			thermal.changed.connect(self._update_shape)
		_update_shape()

@export var particle_velocity_multiplier: float = 4

@export var cloud: Node3D
@export var randomize_cloud_rotation: bool = true

# TODO Maybe export instead of searching?
@export var area: Area3D
@export var area_collision: CollisionShape3D
@export var particles: GPUParticles3D
@export var wind_component: ThermalWindAreaComponent


func _ready():
	if Engine.is_editor_hint() and thermal != null:
		thermal.changed.connect(self._update_shape)
	_update_shape()


func _update_shape():
	assert(is_node_ready())
	if thermal == null:
		return
		
	var half_height := thermal.height / 2.0

	if area_collision != null:
		if not area_collision.shape is CylinderShape3D:
			area_collision.shape = CylinderShape3D.new()
		var cylinder: CylinderShape3D = area_collision.shape
		cylinder.height = thermal.height
		cylinder.radius = thermal.radius
		area_collision.position.y = half_height

	if particles != null:
		var particles_speed := thermal.strength * particle_velocity_multiplier
		var particles_vertical_distance := particles.lifetime * thermal.strength * particle_velocity_multiplier
		var emission_height := thermal.height - particles_vertical_distance
		particles.position.y = emission_height / 2.0

		particles.visibility_aabb.position = Vector3(
			-thermal.radius,
			-particles.position.y,
			-thermal.radius
		)
		particles.visibility_aabb.end = Vector3(
			thermal.radius,
			half_height,
			thermal.radius
		)
		
		if particles.process_material is ParticleProcessMaterial:
			var material := particles.process_material as ParticleProcessMaterial
			material.initial_velocity_max = particles_speed
			material.initial_velocity_min = material.initial_velocity_max
			material.emission_ring_radius = thermal.radius
			material.emission_ring_height = emission_height

		elif particles.process_material is ShaderMaterial:
			# Instance parameters doesn't exist for particle shader material (yet),
			# so duplicate the shader.
			particles.process_material = particles.process_material.duplicate() 
			var material := particles.process_material as ShaderMaterial
			material.set_shader_parameter("height", thermal.height)
			material.set_shader_parameter("radius", thermal.radius)
			material.set_shader_parameter("speed", particles_speed)

	if wind_component != null:
		wind_component.thermal = thermal
		
	if cloud != null:
		if randomize_cloud_rotation:
			cloud.rotation.y = randf_range(-PI, PI)
		
		var cloud_height: float = 0
		if cloud is VisualInstance3D or cloud is MeshInstance3D:
			cloud_height = cloud.get_aabb().size.y
		else:
			for child in cloud.get_children():
				if child is VisualInstance3D or child is MeshInstance3D:
					cloud_height = max(cloud_height, child.get_aabb().size.y)
		cloud.position.y = thermal.height - cloud_height / 2