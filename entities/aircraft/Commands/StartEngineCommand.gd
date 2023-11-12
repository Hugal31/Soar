class_name StartEngingeCommand
extends AircraftCommand


class Param:
	var free_fuel := false

	func _init(free_fuel_: bool):
		self.free_fuel = free_fuel_


func execute(aircraft: Aircraft, data: Object = null):
	if data is Param:
		var previous_fuel := aircraft.fuel_level
		aircraft.start_engine()
		if data.free_fuel:
			aircraft.fuel_level = previous_fuel
