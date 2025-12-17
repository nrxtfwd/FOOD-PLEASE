extends Button

@export var file_name := 'level_1'
@export var level_num : int = 1

func _pressed() -> void:
	get_tree().paused = false
	Global.change_scene(load('res://scenes/'+file_name+ '.tscn'))

func _ready() -> void:
	disabled = Global.levels_unlocked < level_num
	$tick.visible = level_num == Global.scene().level_num
