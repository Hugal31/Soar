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


## Returns a pseudo-random float between 0.0 and 1.0 (inclusive).
func randf() -> float:
	return rng.randf()


func randf_range(from: float, to: float) -> float:
	return rng.randf_range(from, to)


func randfn(mean: float = 0.0, deviation: float = 1.0) -> float:
	return rng.randfn(mean, deviation)


func randi() -> int:
	return rng.randi()


func randi_range(from: int, to: int) -> int:
	return rng.randi_range(from, to)
