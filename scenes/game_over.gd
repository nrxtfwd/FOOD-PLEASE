extends ColorRect

@export var win : ColorRect
@export var work_hour_label : Label
@export var work_hour_status_label : Label
@export var rush_hour_label : Label
@export var food_critics : Label
@export var game_over_desc : RichTextLabel
@export var win_desc : RichTextLabel
@export var win_sound : AudioStreamMP3
@export var lose_sound : AudioStreamMP3

func rush_hour(started = false):
	if started:
		rush_hour_label.text = 'RUSH HOUR!!'
		rush_hour_label.modulate = Color(1,1,1,1)
	else:
		rush_hour_label.text = 'rush hour ended...'
		var tween = get_tree().create_tween()
		tween.tween_property(rush_hour_label,'modulate',Color(1,1,1,0),0.5)

func rush_hour_warning(dur_until):
	rush_hour_label.text = 'RUSH HOUR IN ' + str(dur_until) + ' SECONDS...'
	rush_hour_label.modulate = Color(1,1,1,1)
	await get_tree().create_timer(3.0).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(rush_hour_label,'modulate',Color(1,1,1,0),0.5)

func game_over():
	Global.play(lose_sound)
	get_tree().paused = true
	var mvp = Global.player1 if Global.player1.points > Global.player2.points else Global.player2
	var color : Color = mvp.player_color
	game_over_desc.text = 'cant even put food on the table! Although [color=#' + str(color.to_html(false)) + ']'+str(mvp.player_label)+'[/color] did try their best with [color=' + str(color.to_html(false)) + ']'+str(mvp.points)+ ' Points[/color]...'
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self,'modulate',Color(1,1,1,1),0.5)

func work_hour_changed(work_hour):
	var clock = work_hour + 9
	var ampm = 'AM'
	if clock>=12:
		ampm = 'PM'
	if clock >= 13:
		clock -= 12
	if work_hour >= 7:
		work_hour_status_label.text = 'Last stretch!'
	elif work_hour >= 4:
		work_hour_status_label.text = 'Just ' + str(8-work_hour) + ' more hours!'
	else:
		work_hour_status_label.text = 'Still ' + str(8-work_hour) + ' more hours to go...'
	work_hour_label.text = str(clock) + ampm
	if work_hour >= 8:
		Global.play(win_sound)
		var mvp = Global.player1 if Global.player1.points > Global.player2.points else Global.player2
		var color : Color = mvp.player_color
		win_desc.text = 'survived a day thanks to [color=#' + str(color.to_html(false)) + ']'+str(mvp.player_label)+'[/color] who scored [color=' + str(color.to_html(false)) + ']'+str(mvp.points)+ ' Points[/color]!!'
		var tween = get_tree().create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(win,'modulate',Color(1,1,1,1),0.5)
		get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('restart') and (modulate.a == 1.0 or win.modulate.a == 1.0):
		Global.npc_id = 0
		Global.lives = 3
		get_tree().paused = false
		for food in get_tree().current_scene.find_children('*','Food',true):
			food.queue_free()
		get_tree().reload_current_scene()

func _ready() -> void:
	modulate = Color(1,1,1,0)
	Global.game_over.connect(game_over)
	Global.critics_status.connect(
		func(warning = false):
			if warning:
				food_critics.text = 'FOOD CRITICS IN 60 SECONDS...'
			else:
				food_critics.text = 'FOOD CRITICS ARRIVING IN 5 SECONDS!'
			food_critics.modulate = Color.WHITE
			await get_tree().create_timer(2.0).timeout
			var tween = get_tree().create_tween()
			tween.tween_property(food_critics,'modulate',Color(1,1,1,0),0.5)
	)
	Global.work_hour_changed.connect(work_hour_changed)
	Global.rush_hour.connect(rush_hour.bind(true))
	Global.rush_hour_ended.connect(rush_hour)
	Global.rush_hour_warning.connect(rush_hour_warning)
