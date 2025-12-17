extends RigidBody2D

var cd = 0

func _on_area_body_entered(body: Node2D) -> void:
	if Global.tick() - cd <= 0.5:
		return
	var total_food = 0
	if Global.is_player(get_parent()):
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
	
	var max_x = 1152.0
	var max_y = 648.0
	if Global.scene().level_num == 3:
		max_x = 1277.0
		max_y = 719.0
	global_position.x = clampf(global_position.x, 0.0,max_x)
	global_position.y = clampf(global_position.y, 0.0, max_y)
