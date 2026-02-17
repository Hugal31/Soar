class_name WindManagerComponent
extends Node

@export var horizontal_winds_groups: Node
# The mean wind strenght (roughly in m/s)
@export var wind_distribution_mu: float = 15.
# The sigma for the wind strenght distribution
@export var wind_distribution_sigma: float = 6.

var _chosen_wind_group: Node

const LOGNAME := "WindManagerComponent"


func _ready():
	KLogger.add_module(LOGNAME)
	pick_one_horizontal_wind_group()
	randomize_wind()


func pick_one_horizontal_wind_group():
	var n_groups := horizontal_winds_groups.get_child_count()
	var idx := RandomNumberGeneratorManager.rng.randi_range(0, n_groups - 1)
	for i in range(0, n_groups):
		var child := horizontal_winds_groups.get_child(i)
		if i != idx:
			child.queue_free()
		else:
			_chosen_wind_group = child
			child.visible = true


func randomize_wind():
	var rng := RandomNumberGeneratorManager.rng
	var wind_strenght := rng.randfn(wind_distribution_mu, wind_distribution_sigma)
	if rng.randi() % 2 == 0:
		wind_strenght *= -1.
	KLogger.info("Set wind to %.2f" % wind_strenght, LOGNAME)
	for wind in _chosen_wind_group.get_children():
		if not wind is ProceduralRidgeLift:
			continue
		var lift := wind as ProceduralRidgeLift
		var ridge_lift := lift.ridge_lift
		var new_ridge_lift := ridge_lift.duplicate()
		new_ridge_lift.strength = wind_strenght
		lift.ridge_lift = new_ridge_lift
