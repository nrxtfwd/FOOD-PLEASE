extends CharacterBody2D

@export var speed : float = 200.0
@export var max_food_wait_time : float = 12.0
@export var max_anger_time : float = 10.0
@export var is_critic = false
@export var max_food_rounds = 1
@export var angry_sound : AudioStreamMP3

@onready var col_shape = $col_shape
@onready var waiting_for_food := $waiting_for_food
@onready var sprite := $Sprite2D
@onready var anger_sprite := $anger
@onready var dialogue = $dialogue

var id = 0
var is_birthday = false
var food_rounds = 0
var table_number : int
var table : StaticBody2D
var seated = false
var phase_1 = false
var phase_2 = false
var eaten = false
var start_pos
var end_pos_x = 1220.0
var end_pos_y = 670.0
var wander = 20.0
var anger_rotation = 0
var storm_out = false
var kb = Vector2.ZERO
var lv2_number_temp = 0
var anger_time = 0 :
	set(value):
		if value > 0 and anger_time <= 0:
			Global.play(angry_sound)
			if randf() <= 0.5:
				say("Where's my food?!")
		anger_time = value
		waiting_for_food.value = anger_time/max_anger_time
		modulate = Color.WHITE.lerp(Color.INDIAN_RED, anger_time/max_anger_time)
var food_wait_time = 0 :
	set(value):
		food_wait_time = value
		waiting_for_food.visible = food_wait_time > 0
		waiting_for_food.value = food_wait_time/max_food_wait_time

func say(text):
	dialogue.show()
	dialogue.text = text
	await get_tree().create_timer(4.0).timeout
	dialogue.hide()

func _ready() -> void:
	if Global.scene().level_num == 3:
		end_pos_x = 1300.0
		end_pos_y = 730.0
	if is_critic:
		$star.visible = true
		$critic_light.enabled = true
	else:
		$Sprite2D.modulate = Color.WHITE
		if !is_birthday:
			table_number = randi_range(1,8)
	Global.npc_id += 1
	id = Global.npc_id
	start_pos = global_position
	var tables = get_parent().get_node('tables')
	for this_table in tables.get_children():
		if this_table.table_number == table_number:
			table = this_table
			break

func _physics_process(delta: float) -> void:
	anger_sprite.visible = anger_time > 0 and !eaten
	if anger_time > 0:
		anger_rotation += delta
		anger_sprite.rotation_degrees = fmod(floor(anger_rotation)*60.0,360.0)
	if seated:
		sprite.play('idle')
		col_shape.disabled = true
		if food_wait_time >= max_food_wait_time:
			anger_time += delta
			if anger_time >= max_anger_time:
				for child in get_children():
					if child.name == 'seat':
						child.reparent.call_deferred(table.get_node('seats'))
						break
				seated = false
				var i = 0
				for npc in table.occupiers:
					if npc.id == id:
						table.occupiers.remove_at(i)
						break
					i += 1
				storm_out = true
		else:
			food_wait_time += delta
		return
	sprite.play('walk')
	sprite.flip_h = velocity.x < 0
	waiting_for_food.visible = false
	if global_position.x >= end_pos_x or global_position.y >= end_pos_y or (global_position.x <= -20.0 and (eaten or storm_out)):
		if storm_out:
			Global.lives -= 1
		queue_free()
		return
	var find_self_in_seated = table.occupiers.find(self)
	var level_num = Global.scene().level_num
	if find_self_in_seated != -1:
		var table_x = table.global_position.x
		var table_y = table.global_position.y
		var target_pos := Vector2(table_x+60.0,global_position.y)
		# level 1
		if Global.scene().level_num == 1 or level_num == 3:
			if abs(global_position.x - (table_x+60.0)) <= 5.0 or phase_1:
				phase_1 = true
				var y = table.global_position.y
				target_pos = Vector2(table_x+60.0 , y)
				if abs(global_position.y - y) <= 10.0:
					target_pos = Vector2(table_x,y)
		elif level_num == 2:
			target_pos = Vector2(global_position.x, table_y+80.0)
			if abs(global_position.y - target_pos.y) <= 5.0 or phase_1:
				phase_1 = true
				target_pos = Vector2(table_x, table_y+80.0)
				lv2_number_temp = table_y+80.0
				if abs(global_position.x - table_x) <= 3.0:
					target_pos = Vector2(table_x,table_y)
		velocity = global_position.direction_to(target_pos) * speed
	else:
		for npc in table.occupiers:
			if !is_instance_valid(npc) or npc.eaten or npc.storm_out:
				table.occupiers.erase(npc)
		if len(table.occupiers) < table.max_occupiers:
			table.occupiers.append(self)
		else:
			velocity = Vector2(wander,0)
	if eaten or storm_out:
		var target_pos = Vector2(global_position.x,start_pos.y)
		if level_num == 1 or level_num == 3:
			if abs(target_pos.y - global_position.y) <= 9.0 or phase_2:
				col_shape.disabled = false
				phase_2 = true
				target_pos = Vector2(-100.0 if level_num == 3 else end_pos_x,start_pos.y)
		elif level_num == 2:
			target_pos = Vector2(global_position.x, lv2_number_temp)
			if abs(target_pos.y - global_position.y) <= 9.0 or phase_2:
				col_shape.disabled = false
				phase_2 = true
				target_pos = Vector2(start_pos.x,global_position.y)
				if abs(start_pos.x - global_position.x) <= 5.0:
					target_pos = Vector2(start_pos.x, 680.0)
		velocity = global_position.direction_to(target_pos) * speed
	velocity += kb * delta
	kb = kb.move_toward(Vector2.ZERO, speed*0.5)
	move_and_slide()
