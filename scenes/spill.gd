extends Area2D

func _on_body_entered(body: Node2D) -> void:
	body.kb += Vector2.RIGHT.rotated(2.0 * PI * randf()) * 300.0
	if body is Player:
		body.walking_on_spill = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.walking_on_spill = false
