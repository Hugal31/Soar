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

# TODO Maybe export instead of searching?
var area: Area3D
var area_collision: CollisionShape3D
var particles: GPUParticles3D
var wind_component: ThermalWindAreaComponent


func _ready():
	child_entered_tree.connect(_update_children)
	child_exiting_tree.connect(_update_children)
	if thermal != null:
		thermal.changed.connect(self._update_shape)
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
	if uc:
		_update_shape()


func _update_shape():
	if thermal == null:
		return
	print_debug("update", self, thermal, area_collision, area_collision.shape)

	if area_collision != null:
		if not area_collision.shape is CylinderShape3D:
			area_collision.shape = CylinderShape3D.new()
		var cylinder: CylinderShape3D = area_collision.shape
		cylinder.height = thermal.height
		cylinder.radius = thermal.radius
		area_collision.position.y = thermal.height / 2.0

	if particles != null and particles.material is ParticleProcessMaterial:
		var material := particles.material as ParticleProcessMaterial
		material.emission_ring_radius = thermal.radius

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
