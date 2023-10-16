extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body is Aircraft:
		var aircraft: Aircraft = body
		aircraft.on_enter_wind_area($ThermalWindAreaComponent)


func _on_body_exited(body):
	if body is Aircraft:
		var aircraft: Aircraft = body
		aircraft.on_exit_wind_area($ThermalWindAreaComponent)
