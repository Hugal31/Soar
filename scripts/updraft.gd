extends Area3D


var aircrafts: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for aircraft in aircrafts:
		var horizontal_distance: float = (aircraft.global_position - global_position).length()
		aircraft.wind_vertical_speed = 1 + 6 * exp(-horizontal_distance / 50)


func _on_body_entered(body):
	aircrafts.push_back(body)


func _on_body_exited(body):
	aircrafts.remove_at(aircrafts.find(body))
	body.wind_vertical_speed = 0
