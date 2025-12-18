extends ColorRect

@export var show_main_menu = true
@export var anim_player : AnimationPlayer

@onready var tut1 = $level1_tutorial
@onready var tut2 = $level2_tutorial
@onready var tut3 = $level3_tutorial

var tut

signal enter_game

func _ready() -> void:
	if show_main_menu:
		show()
		get_tree().paused = true
		await get_tree().create_timer(0.02).timeout
		anim_player.play('menu_start')
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
			$MarginContainer.hide()
			match Global.scene().level_num:
				1: tut = tut1
				2: tut = tut2
				3: tut = tut3
			tut.show()
