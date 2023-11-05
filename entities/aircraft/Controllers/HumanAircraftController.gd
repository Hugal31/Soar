class_name  HumanAircraftController
extends AircraftController


func _physics_process(_delta):
	if Input.is_action_just_pressed("brake"):
		pull_out_airbrakes_command.execute(aircraft)
	elif Input.is_action_just_released("brake"):
		store_airbrakes_command.execute(aircraft)

	bank_command.execute(aircraft, BankCommand.Param.new(Input.get_axis("left", "right"), Input.is_action_pressed("high_bank")))
	pitch_command.execute(aircraft, PitchCommand.Param.new(Input.get_axis("backward", "forward")))
