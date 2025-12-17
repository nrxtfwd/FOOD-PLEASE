extends ColorRect

@export var show_main_menu = true
@onready var tut1 = $level1_tutorial
@onready var tut2 = $level2_tutorial
@onready var tut3 = $level3_tutorial

signal enter_game

func _ready() -> void:
	if show_main_menu:
		show()
		get_tree().paused = true
	else:
		hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		if tut1.visible or tut2.visible or tut3.visible:
			enter_game.emit()
			get_tree().paused = false
			queue_free()
		else:
			$menu.hide()
			match Global.scene().level_num:
				1: tut1.show()
				2: tut2.show()
				3: tut3.show()
