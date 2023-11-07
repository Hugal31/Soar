class_name AircraftController
extends Node

var aircraft: Aircraft

var bank_command := BankCommand.new()
var pitch_command := PitchCommand.new()
var pull_out_airbrakes_command = PullOutAirbrakesCommand.new()
var store_airbrakes_command = StoreAirbrakesCommand.new()


func _init(aircraft_: Aircraft):
	self.aircraft = aircraft_
