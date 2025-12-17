extends Node

signal order_food
signal lives_changed
signal work_hour_changed
signal game_over
signal rush_hour_warning
signal rush_hour
signal rush_hour_ended
signal critics_status

var levels_unlocked = 2
var bg_music
var sfx_volume = -15.0
var player1
var player2
var npc_id = 0
var work_hour = 0 :
	set(value):
		work_hour = value
		work_hour_changed.emit(work_hour)
var lives = 3 :
	set(value):
		lives = value
		if lives <= 0:
			game_over.emit()
		lives_changed.emit(lives)

func is_player(body):
	return 'holding' in body

func change_scene(scene):
	get_tree().change_scene_to_packed(scene)

func tick():
	return Time.get_ticks_msec()/1000.0

func scene():
	return get_tree().current_scene

func play(file):
	var audio = AudioStreamPlayer.new()
	audio.stream = file
	audio.volume_db = sfx_volume
	get_tree().current_scene.add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()
	
	
	
	
