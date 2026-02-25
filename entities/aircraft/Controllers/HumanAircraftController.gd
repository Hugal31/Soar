class_name HumanAircraftController
extends AircraftController


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("brake"):
		if event.is_pressed():
			pull_out_airbrakes_command.execute(aircraft)
		elif event.is_released():
			store_airbrakes_command.execute(aircraft)
		else:
			KLogger.warn("Action neither pressed or released??")
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event.is_action_pressed("cheat_engine"):
		start_engine_command.execute(aircraft, StartEngingeCommand.Param.new(true))
		get_viewport().set_input_as_handled()


func _physics_process(_delta):
	bank_command.execute(
		aircraft,
		BankCommand.Param.new(Input.get_axis("left", "right"), Input.is_action_pressed("high_bank"))
	)
	pitch_command.execute(aircraft, PitchCommand.Param.new(Input.get_axis("backward", "forward")))
