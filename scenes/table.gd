extends StaticBody2D

@export var table_number := 1
@export var max_occupiers := 4
@export var sound : AudioStreamMP3
@export var default_col_shape : Shape2D
@export var area_col_shape : CollisionShape2D
@export var level3_col_shape : Shape2D

@onready var seats = $seats

var occupier
var occupiers = []
var dirty_plates = 0 :
	set(value):
		dirty_plates = value
		var i = 0
		for dp in get_children():
			if dp.name.left(11) == 'dirty_plate':
				dp.hide()
				i += 1
				if dirty_plates >= i:
					dp.show()

func _ready() -> void:
	var level_num = Global.scene().level_num
	if level_num == 3:
		seats.get_node('seat1').queue_free.call_deferred()
		seats.get_node('seat3').queue_free.call_deferred()
	area_col_shape.shape = level3_col_shape if level_num == 3 else default_col_shape
	$CollisionShape2D.shape = area_col_shape.shape
	$CollisionShape2D.disabled = level_num == 2
	$level_2.disabled = level_num != 2
	$table_number.text = str(table_number)

func process_npc(highest_npc, entity, is_cake = false):
	Global.play(sound)
	$AnimationPlayer.play('served')
	for child in highest_npc.get_children():
		if child.name.left(4) == 'seat':
			child.reparent.call_deferred(seats)
	var i = 0
	highest_npc.food_rounds += 1
	if highest_npc.food_rounds >= highest_npc.max_food_rounds:
		highest_npc.seated = false
		highest_npc.eaten = true
		if Global.scene().level_num == 2:
			
			var n = 0
			if randf() <= 0.2:
				n = randi_range(1,2)
			dirty_plates = min(dirty_plates+ n, 2)
		for npc in occupiers:
			if is_instance_valid(npc):
				if npc.id == highest_npc.id:
					occupiers.remove_at(i)
					break
			i += 1
	else:
		Global.order_food.emit(table_number)
		highest_npc.say("I want more!!")
		highest_npc.food_wait_time = 0
		highest_npc.anger_time = 0
	if highest_npc.is_critic:
		entity.points += 5
	else:
		entity.points += 3 if is_cake else 1

func _on_area_body_entered(entity: Node2D) -> void:
	if Global.is_player(entity):
		if dirty_plates > 0:
			var allowed = 3-len(entity.holding)
			if allowed > 0:
				if entity.dirty_plates == 0:
					entity.dirty_plates += dirty_plates
					dirty_plates = 0
				elif entity.dirty_plates == 1:
					entity.dirty_plates += 1
					dirty_plates -= 1
		
		for food in entity.get_children():
			if 'table_number' in food and food.table_number == table_number:
				entity.holding.erase(food)
				food.queue_free()
				var highest_wait_time = 0
				var highest_npc
				for npc in occupiers:
					if is_instance_valid(npc):
						if npc.eaten or npc.storm_out:
							occupiers.erase(npc)
							continue
						if npc.food_wait_time + npc.anger_time > highest_wait_time:
							if food.is_cake:
								process_npc(npc, entity, true)
							else:
								highest_wait_time = npc.food_wait_time + npc.anger_time
								highest_npc = npc
				if highest_npc:
					process_npc(highest_npc, entity)
	else:
		if entity.table_number != table_number:
			return
		if entity.eaten or entity.storm_out:
			return
		if len(seats.get_children()) <= 0:
			entity.eaten = true
			return
		var seat = get_node('seats').get_children()[0]
		entity.seated = true
		entity.table = self
		entity.get_node('Sprite2D').flip_h = !seat.get_meta('flip')
		entity.get_node('waiting_for_food').visible = false
		entity.global_position = seat.global_position
		seat.reparent.call_deferred(entity)
		seat.name = 'seat'
		if entity.is_birthday:
			Global.order_food.emit(table_number)
		else:
			Global.order_food.emit(table_number)
