class_name StoreAirbrakesCommand
extends AircraftCommand


func execute(aircraft: Aircraft, data: Object = null):
	aircraft.store_air_brakes()
