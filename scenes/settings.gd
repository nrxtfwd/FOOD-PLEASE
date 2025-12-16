extends PanelContainer

@export var button : TextureButton
@export var control : Control

func mouse_entered():
	button.modulate = Color.WHITE

func mouse_exited():
	button.modulate = 0x909090ff

func _ready() -> void:
	button.mouse_entered.connect(mouse_entered)
	button.mouse_exited.connect(mouse_exited)

func _on_settings_pressed() -> void:
	visible = !visible

func _on_close_pressed() -> void:
	visible = false

func _on_music_value_changed(value: float) -> void:
	Global.bg_music.volume_db = -15.0 + ((value-0.5) * 30.0)

func _on_sfx_value_changed(value: float) -> void:
	Global.sfx_volume = -15.0 + ((value-0.5) * 30.0)

func _on_main_menu_enter_game() -> void:
	reparent.call_deferred(control)
