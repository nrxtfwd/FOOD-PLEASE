extends PanelContainer

@export var settings : PanelContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('escape'):
		visible = !visible
		get_tree().paused = visible

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_settings_pressed() -> void:
	settings.show()

func _on_menu_pressed() -> void:
	get_tree().reload_current_scene()
