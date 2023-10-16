extends Label


func _on_vector_changed(v: Vector3):
	self.text = "(x: %.4f, y: %.4f, z: %.4f)" % [v.x, v.y, v.z]
