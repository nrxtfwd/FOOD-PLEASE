extends RigidBody2D

var cd = 0

func _on_area_body_entered(body: Node2D) -> void:
	if Global.tick() - cd <= 0.5:
		return
	var total_food = 0
	if get_parent() is Player:
		return
	if len(body.holding) >= 3:
		return
	body.holding.append(self)
	reparent.call_deferred(body)
	$drop.show()
	rotation = 0
	call_deferred('set', 'process_mode', PROCESS_MODE_DISABLED)
	body.interacted.connect(interacted)

func interacted():
	cd = Global.tick()
	$drop.hide()
	get_parent().interacted.disconnect(interacted)
	get_parent().holding.erase(self)
	reparent.call_deferred(get_tree().current_scene)
	call_deferred('set', 'process_mode', PROCESS_MODE_INHERIT)

func _physics_process(delta: float) -> void:
	global_position.x = clampf(global_position.x, 0.0,1152.0)
	global_position.y = clampf(global_position.y, 0.0, 648.0)
