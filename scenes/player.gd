extends CharacterBody2D

const SPILL = preload("uid://bjprfu537xvt4")

@export var speed : float = 350.0
@export var accel : float = 50.0
@export var player_color : Color
@export var player_label : String = 'P1'
@export var left : String = 'left'
@export var right : String = 'right'
@export var up : String = 'up'
@export var down : String = 'down'
@export var interact : String = 'interact'

@onready var sprite = $Sprite2D
@onready var walking = $walking
@onready var dp1 = $dirty_plate1
@onready var dp2 = $dirty_plate2

signal interacted

var dirty_plates = 0:
	set(value):
		dirty_plates = value
		dp1.visible = dirty_plates >= 1
		dp2.visible = dirty_plates >= 2
		if dp1.visible:
			if holding.find(dp1) == -1:
				holding.append(dp1)
		else:
			if holding.find(dp1) != -1:
				holding.erase(dp1)
		if dp2.visible:
			if holding.find(dp2) == -1:
				holding.append(dp2)
		else:
			if holding.find(dp2) != -1:
				holding.erase(dp2)
var holding = []
var walking_on_spill = false
var points = 0 :
	set(value):
		var particle := $plus_one.duplicate()
		particle.amount = value-points
		particle.emitting = true
		particle.modulate = player_color
		particle.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(particle)
		particle.finished.connect(
			func():
				particle.queue_free()
		)
		points = value
var kb = Vector2.ZERO
var last_vector

func _ready() -> void:
	if player_label == 'P1':
		Global.player1 = self
	else:
		Global.player2 = self
	$player_label.text = player_label
	$player_label.modulate = player_color
	sprite.modulate = player_color

func _physics_process(delta: float) -> void:
	var max_x = 1152.0
	var max_y = 648.0
	var is_speed_boost = len($speed_boost_area.get_overlapping_areas()) > 0
	if Global.scene().level_num == 3:
		max_x = 1277.0
		max_y = 719.0
	global_position.x = clampf(global_position.x, 0.0,max_x)
	global_position.y = clampf(global_position.y, 0.0, max_y)
	$max_food.visible = len(holding) >= 3
	var vector := Input.get_vector(left,right,up,down)
	speed = 350.0 - (len(holding) *30.0)
	$speed_boost.emitting = is_speed_boost
	if vector.length() > 0:
		var mul = 1.0
		if is_speed_boost:
			mul = 1.5
		for hold in holding:
			if hold is Food and hold.is_cake:
				mul *= 0.7
		velocity = velocity.move_toward(vector * speed * mul, accel)
		last_vector = vector
		sprite.flip_h = vector.x < 0
		sprite.play('walk')
		walking.scale.x = 1.0 if vector.x < 0 else -1.0
	else:
		sprite.play('idle')
		velocity = velocity.move_toward(Vector2.ZERO, accel)
	walking.emitting = vector.length() > 0
	$spill_walking.emitting = walking.emitting and walking_on_spill
	#if last_vector:
		#rotation = lerp_angle(rotation, last_vector.angle(), 0.1)
	velocity += kb * delta * 20.0
	kb = kb.move_toward(Vector2.ZERO, accel*0.1)
	kb *= 0.95
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(interact):
		interacted.emit()

func _on_npc_hurtbox_body_entered(body: Node2D) -> void:
	if body == self:
		return
	for hold in holding:
		if !is_instance_valid(hold):
			holding.erase(hold)
			continue
		if is_instance_valid(hold) and hold is Food and hold.is_water:
			Global.order_food.emit(hold.table_number, true)
			var spill = SPILL.instantiate()
			spill.global_position = global_position + (velocity.normalized() * 50.0)
			get_tree().current_scene.add_child.call_deferred(spill)
			Global.play(load('res://music/GlassBreak.mp3'))
			holding.erase(hold)
			hold.queue_free()
			
	kb = body.global_position.direction_to(global_position) * speed * 0.7
	if Global.is_player(body):
		kb *= 0.7
