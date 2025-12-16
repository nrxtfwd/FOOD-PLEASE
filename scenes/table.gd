extends StaticBody2D

@export var table_number := 1
@export var max_occupiers := 4
@export var sound : AudioStreamMP3

@onready var seats = $seats

var occupier
var occupiers = []

func _ready() -> void:
	$table_number.text = str(table_number)

func _on_area_body_entered(entity: Node2D) -> void:
	if entity is Player:
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
						if npc.food_wait_time > highest_wait_time:
							highest_wait_time = npc.food_wait_time
							highest_npc = npc
				if highest_npc:
					Global.play(sound)
					$AnimationPlayer.play('served')
					for child in highest_npc.get_children():
						if child.name.left(4) == 'seat':
							print('seat go back')
							child.reparent.call_deferred(seats)
					var i = 0
					highest_npc.food_rounds += 1
					if highest_npc.food_rounds >= highest_npc.max_food_rounds:
						highest_npc.seated = false
						highest_npc.eaten = true
						for npc in occupiers:
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
						entity.points += 1
	else:
		if entity.table_number != table_number:
			return
		if entity.eaten or entity.storm_out:
			return
		if len(seats.get_children()) <= 0:
			entity.eaten = true
			return
		var seat = seats.get_children()[0]
		entity.seated = true
		entity.table = self
		entity.get_node('Sprite2D').flip_h = !seat.get_meta('flip')
		entity.get_node('waiting_for_food').visible = false
		entity.global_position = seat.global_position
		seat.reparent.call_deferred(entity)
		seat.name = 'seat'
		Global.order_food.emit(table_number)
