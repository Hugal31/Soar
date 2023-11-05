class_name PullOutAirbrakesCommand
extends AircraftCommand


func execute(aircraft: Aircraft, _data: Object = null):
	aircraft.pull_out_air_brakes()
