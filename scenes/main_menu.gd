extends ColorRect

@export var show_main_menu = true
@onready var tut = $tutorial

func _ready() -> void:
	if show_main_menu:
		show()
		get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		if tut.visible:
			get_tree().paused = false
			queue_free()
		else:
			$menu.hide()
			tut.visible = true
