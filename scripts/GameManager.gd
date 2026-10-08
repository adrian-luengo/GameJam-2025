extends Node

@export var max_time_sec := 300   # 5 minutos en segundos

var current_time_sec := max_time_sec
var current_wave := 0
var is_dialogue_on: bool = false

var dialogue_wave_earned_this_turn: bool = false
signal dialogue_wave_earned

const CANVAS_LAYER = preload("uid://dg1dmncrf56jj")
var ui_instance: Node
var label_timer: Label
var label_waves: Label

@onready var countdown_timer: Timer = Timer.new()
signal wave_substracted

func _ready():
	ui_instance = CANVAS_LAYER.instantiate()
	add_child(ui_instance)

	label_timer = ui_instance.get_node("timer")
	label_waves = ui_instance.get_node("waves")

	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.autostart = false
	add_child(countdown_timer)
	countdown_timer.connect("timeout", Callable(self, "_on_timeout"))
	
	update_ui()

func start_timer() -> void:
	countdown_timer.start()

func _on_timeout():
	if is_dialogue_on:
		return
	
	if current_time_sec > 0:
		current_time_sec -= 1
		update_ui()
	else:
		countdown_timer.stop()
		game_over()


func add_wave():
	current_wave += 1
	update_ui()
	ui_instance.get_node("Waving_hand/AnimationPlayer").play("wave")

func subtract_wave(num :int):
	if current_wave == 0:
		return
	else:
		current_wave = max(0,current_wave-num)
		print("GM: compensation")
		wave_substracted.emit()
		update_ui()


func update_ui():
	@warning_ignore("integer_division")
	var minutos := int(current_time_sec) / 60
	var segundos := int(current_time_sec) % 60
	if label_waves:
		label_waves.text = "%d" % current_wave
	if label_timer:
		label_timer.text = "%02d:%02d" % [minutos, segundos]
		

func game_over():
	if get_tree().current_scene.name != "CIC":
		return

	print("Fin del juego")
	
	var game_over_screen = get_tree().current_scene.get_node_or_null("GAMEOVER")
	
	if game_over_screen:
		game_over_screen.show()
	else:
		print("ERROR: No encuentro el nodo 'GameOver' dentro de ui_instance")
	get_tree().paused = true

func game_win():
	if get_tree().current_scene.name != "CIC":
		return

	print("Fin del juego")
	
	var game_over_screen = get_tree().current_scene.get_node_or_null("GAMEWIN")
	
	if game_over_screen:
		game_over_screen.show()
	else:
		print("ERROR: No encuentro el nodo 'GameOver' dentro de ui_instance")
	get_tree().paused = true
	print("FIN DE JUEGO")
	
	
func reset_game_data() -> void:
	current_time_sec = max_time_sec
	current_wave = 0
	is_dialogue_on = false
	
	if countdown_timer.is_stopped():
		countdown_timer.start()
	update_ui()
	
func set_dialogue_on(status: bool) -> void:
	is_dialogue_on = status
	print("is_dialogue_on set to: "+str(is_dialogue_on))

func reset_dialogue_wave() -> void:
	dialogue_wave_earned_this_turn = false

	
func set_dialogue_wave(_status:bool)->void:
	dialogue_wave_earned_this_turn = true

func mark_dialogue_wave_earned() -> void:
	dialogue_wave_earned_this_turn = true
	dialogue_wave_earned.emit()

func get_dialogue_result() -> bool:
	return dialogue_wave_earned_this_turn
