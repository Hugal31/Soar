@tool
extends Node3D
class_name ProceduralThermal


@export var thermal: Thermal:
	set(t):
		# Check if this is called before or after _ready, if it is called at all.
		if thermal != null:
			thermal.changed.disconnect(self._update_shape)
		thermal = t
		if thermal != null:
			thermal.changed.connect(self._update_shape)
		_update_shape()

@export var particle_velocity_multiplier: float = 4

# TODO Maybe export instead of searching?
var area: Area3D
var area_collision: CollisionShape3D
var particles: GPUParticles3D
var wind_component: ThermalWindAreaComponent


func _ready():
	child_entered_tree.connect(_update_children)
	child_exiting_tree.connect(_update_children)
	_update_children()


func _update_children(uc=true, _child=null):
	for child in get_children():
		if child is Area3D:
			area = child
			for area_child in area.get_children():
				if area_child is CollisionShape3D:
					area_collision = area_child
					break

		if child is GPUParticles3D:
			particles = child

		if child is ThermalWindAreaComponent:
			wind_component = child

	update_configuration_warnings()
	_update_shape()


func _update_shape():
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


func _get_configuration_warnings():
	var warnings = []

	if thermal == null:
		warnings.append("No thermal resource")

	if area == null:
		warnings.append("Needs an Area3D to work")
	elif area_collision == null:
		warnings.append("The Area3D needs a CollisionShape3D to work")

	if wind_component == null:
		warnings.append("Needs a WindAreaComponent")

		return warnings
