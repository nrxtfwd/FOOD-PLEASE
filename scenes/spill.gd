extends Area2D

func _ready() -> void:
	await get_tree().create_timer(12.0).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.get_node_or_null('mop'):
		body.points += 1
		queue_free()
		return
	body.kb += Vector2.RIGHT.rotated(2.0 * PI * randf()) * 300.0
	if body is Player:
		body.walking_on_spill = true
	else:
		if randf() <= 0.5:
			body.say("This place is dirty! Spills everywhere!")

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.walking_on_spill = false
