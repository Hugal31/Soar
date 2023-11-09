extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const LOGNAME := "RandomNumberGeneratorManager"


func _ready():
	Logger.add_module(LOGNAME)
	set_random()


func set_random():
	Logger.info("Use random seed", LOGNAME)
	rng = RandomNumberGenerator.new()


func use_day_seed():
	var timestamp := int(Time.get_unix_time_from_system())
	# TODO Make something more explicitely synced with a specific hour.
	rng.seed = timestamp / (60 * 60 * 24)
	Logger.info("Use day seed %d" % rng.seed, LOGNAME)
