extends Area2D

func _on_body_entered(player: Node2D) -> void:
	if player.dirty_plates > 0:
		player.points += player.dirty_plates
		var dish = $dish.duplicate()
		dish.emitting = true
		dish.amount = player.dirty_plates
		add_child.call_deferred(dish)
		dish.finished.connect(
			func():
				dish.queue_free()
		)
	player.dirty_plates = 0
	player.walking_on_spill = true
	

func _on_body_exited(player: Node2D) -> void:
	player.walking_on_spill = false
