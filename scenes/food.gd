extends RigidBody2D
class_name Food

@export var textures : Array[Texture2D] = []
@export var sound : AudioStreamMP3
@export var water_texture : Texture2D
@export var is_water = false

var table_number

func _ready() -> void:
	#table_number = randi_range(1,8)
	$sprite.texture = textures.pick_random()
	$table_number.text = str(table_number)
	if is_water:
		$sprite.texture = water_texture
		$sprite.scale = Vector2.ONE * 0.8

func _on_area_body_entered(body: Node2D) -> void:
	var total_food = 0
	if get_parent() is Player:
		return
	if len(body.holding) >= 3:
		return
	body.holding.append(self)
	Global.play(sound)
	reparent.call_deferred(body)
	call_deferred('set', 'process_mode', PROCESS_MODE_DISABLED)
