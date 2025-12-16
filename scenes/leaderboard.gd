extends VBoxContainer

var p1score
var p2score

func _ready() -> void:
	p1score = $temp.duplicate()
	p1score.show()
	add_child.call_deferred(p1score)
	p2score = p1score.duplicate()
	add_child.call_deferred(p2score)

func _process(delta: float) -> void:
	p1score.text = 'Player 1: ' + str(Global.player1.points)
	p2score.text = 'Player 2: ' + str(Global.player2.points)
