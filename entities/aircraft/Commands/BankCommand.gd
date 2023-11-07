class_name BankCommand
extends AircraftCommand


class Param:
	# Angle "power" -1 to 1
	var power: float
	var high_bank: bool

	func _init(power_: float, high_bank_: bool):
		self.power = power_
		self.high_bank = high_bank_


func execute(aircraft: Aircraft, data: Object = null):
	if data is Param:
		var param := data as Param
		var max_bank_angle := (
			aircraft.high_bank_angle if param.high_bank else aircraft.regular_bank_angle
		)
		var target_bank = param.power * max_bank_angle
		aircraft.set_bank(target_bank)
