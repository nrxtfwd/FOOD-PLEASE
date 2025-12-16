extends HBoxContainer

@onready var temp = $temp

func lives_changed(lives):
	for child in get_children():
		if child != temp:
			child.queue_free()
	for n in range(lives):
		var cl = temp.duplicate()
		cl.show()
		add_child(cl)

func _ready() -> void:
	temp.hide()
	lives_changed(Global.lives)
	Global.lives_changed.connect(lives_changed)
