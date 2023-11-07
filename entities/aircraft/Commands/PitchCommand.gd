class_name PitchCommand
extends AircraftCommand


class Param:
	# Angle "power" -1 (slow) to 1 (fast)
	var power: float

	func _init(power_: float):
		self.power = power_


func execute(aircraft: Aircraft, data: Object = null):
	if data is Param:
		var param := data as Param
		if param.power >= 0.5:
			aircraft.set_pitch(Aircraft.Pitch.Fast)
		elif param.power <= -0.5:
			aircraft.set_pitch(Aircraft.Pitch.Slow)
		else:
			aircraft.set_pitch(Aircraft.Pitch.Normal)
