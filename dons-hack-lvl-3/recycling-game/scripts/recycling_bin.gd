extends Node3D

var cleared = 0
func _on_area_3d_body_entered(body):
	if (body.is_in_group("recycling") || body.get_parent().is_in_group("recycling")):
		cleared += 1
		body.queue_free()

func clear_items():
	var amount = cleared
	cleared = 0
	return amount
