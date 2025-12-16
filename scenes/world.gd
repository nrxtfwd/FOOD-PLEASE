extends Node2D

@export var max_npcs = 32
@export var npc_spawn_pos : Node2D
@export var npc_spawn_min_time := 2.0
@export var npc_spawn_max_time := 4.0
@export var rush_hour_spawn_time = 2.0

const FOOD = preload("uid://j5demmk8rn2e")
const NPC = preload("uid://chnpqygrmmy6b")

var stage = 0

@onready var npc_spawn = $npc_spawn

var spawn_critics = true
var tick = 0
var is_rush_hour = false

func spawn_food(table_number):
	if tick <= 3.0:
		return
	$food_position.get_node("AnimationPlayer").stop()
	$food_position.get_node("AnimationPlayer").play('fade')
	var food : RigidBody2D = FOOD.instantiate()
	food.global_position = $food_position.position+Vector2(
		(randf()-0.5) * 200.0,
		0
	)
	food.table_number = table_number
	food.apply_central_impulse(Vector2(0,100))
	get_parent().add_child.call_deferred(food)

func _ready() -> void:
	$bg_music.play()
	Global.work_hour = 0
	Global.lives = 3
	Global.order_food.connect(spawn_food)

func _process(delta: float) -> void:
	tick += delta

func _on_npc_spawn_timeout() -> void:
	var count = get_tree().get_node_count_in_group('npc')
	if count >= max_npcs:
		return
	if !is_rush_hour:
		npc_spawn.wait_time = randf_range(npc_spawn_min_time,npc_spawn_max_time)
		npc_spawn.wait_time *= 0.8
	var max_amnt = randi_range(1,stage+1)
	if stage == 0:
		max_amnt = 1
	for n in range(max_amnt):
		var npc = NPC.instantiate()
		npc.global_position = npc_spawn_pos.global_position+Vector2(n*-50.0,0)
		add_child.call_deferred(npc)

func _on_work_hour_timeout() -> void:
	Global.work_hour += 1


func _on_rush_hour_countdown_timeout() -> void:
	stage += 1
	if stage > 2:
		stage = 0
	if stage == 1:
		Global.rush_hour_warning.emit(60)
	elif stage == 2:
		Global.rush_hour.emit()
		is_rush_hour =true
		npc_spawn.wait_time = rush_hour_spawn_time
	elif stage == 0:
		Global.rush_hour_ended.emit()
		is_rush_hour = false

func _on_food_critic_timeout() -> void:
	#spawn_critics = !spawn_critics
	#if !spawn_critics:
		#Global.critics_status.emit(true)
		#return
	#else:
		#
	Global.critics_status.emit()
	await get_tree().create_timer(5.0).timeout
	var sel_table
	while !sel_table:
		for table in $tables.get_children():
			var num_occ = 0
			for occ in table.occupiers:
				if is_instance_valid(occ) and !occ.eaten and !occ.storm_out:
					num_occ += 1
			if num_occ <= 0:
				sel_table = table
				break
		await get_tree().create_timer(1.0).timeout
	prints('SELECTED TABLE', sel_table)
	for n in range(4):
		var npc = NPC.instantiate()
		npc.is_critic = true
		npc.max_food_wait_time *= 0.6 
		npc.max_food_rounds = randi_range(3,5)
		npc.table_number = sel_table.table_number
		npc.global_position = npc_spawn_pos.global_position+Vector2(n*-50.0,randi_range(-1,1)*50.0)
		add_child.call_deferred(npc)
