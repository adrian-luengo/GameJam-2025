extends CharacterBody2D

class_name jugadorAbstracto

var lugaresInteres:Array[Vector2]
@export var max_waves_to_give:int
var waves_to_give:int
var dialogue_completed:bool = false
@export var speed: float = 50
@export var animated_sprite_2d: AnimatedSprite2D
@export var interr: AnimatedSprite2D
@export var cooldown_saludo := 5.0
@export var saludo_meme: AnimatedSprite2D
var ultimo_saludo := -999.0
var esta_saludando := false
@export var sitios_de_interes: Node2D
@export var navigation_agent_2d: NavigationAgent2D
@export var acceleration = 7

var current_target: Vector2
var is_moving_to_target := false
var player_nearby := false

@export var jugador: CharacterBody2D
@export var conversation_name:String

var last_position: Vector2
@export var stuck_threshold: float = 1.5
@export var stuck_distance_threshold: float = 1
var stuck_timer: float = 0.0


func _on_wave_substracted()->void:
	print(str(self)+"compensation")
	waves_to_give = min(max_waves_to_give, waves_to_give + 1)
	
func _ready() -> void:
	saludo_meme.hide()
	interr.hide()
	if not is_connected("wave_substracted", _on_wave_substracted):
		GameManager.wave_substracted.connect(_on_wave_substracted)
		waves_to_give = max_waves_to_give
	for childs in sitios_de_interes.get_children():
		if childs is Marker2D:
			lugaresInteres.push_back(childs.global_position)
	if lugaresInteres.size() > 0:
		_set_new_target()

	if jugador and jugador.has_node("wave_area"):
		var wave_area = jugador.get_node("wave_area")
		wave_area.body_entered.connect(_on_player_near)
		wave_area.body_exited.connect(_on_player_away)

func wave_back():
	if esta_saludando:
		return
	if dialogue_completed:
		_give_waves_to_player()
	else :
		esta_saludando = true
		interr.show()
		interr.play("interrogacion")
		await interr.animation_finished
		interr.hide()
		esta_saludando = false


func _update_animation(dir: Vector2) -> void:
	if dir.length() < 0.1:
		animated_sprite_2d.play("idle")
		return
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animated_sprite_2d.play("derecha")
		else:
			animated_sprite_2d.play("izquierda") 
	else:
		if dir.y > 0:
			animated_sprite_2d.play("abajo")
		else:
			animated_sprite_2d.play("arriba")

			
func _set_new_target() -> void:
	if lugaresInteres.size() == 0:
		return
	
	current_target = lugaresInteres[randi() % lugaresInteres.size()]
	navigation_agent_2d.target_position = current_target
	is_moving_to_target = true

func _process(delta: float) -> void:
	if GameManager.is_dialogue_on:
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		_update_animation(Vector2.ZERO)  # Idle
		return
	
	# Si el jugador está cerca, se para
	if player_nearby:
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		_update_animation(Vector2.ZERO)  
		stuck_timer = 0.0
		if !dialogue_completed and Input.is_action_pressed("start_conversation") and GameManager.is_dialogue_on == false:
			GameManager.is_dialogue_on = true
	
			if Dialogic.timeline_exists(conversation_name):
				Dialogic.start_timeline(conversation_name)
				await Dialogic.timeline_ended
				if is_in_group("director"):
					GameManager.game_win()
					return
				if GameManager.get_dialogue_result():
					waves_to_give-=1
					dialogue_completed = true
					GameManager.reset_dialogue_wave()
				GameManager.is_dialogue_on = false
			return
	
	# Si llegó al destino, busca uno nuevo
	if navigation_agent_2d.is_navigation_finished() and is_moving_to_target:
		is_moving_to_target = false
		stuck_timer = 0.0
		_set_new_target()
		return
	
	if not is_moving_to_target:
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		_update_animation(Vector2.ZERO)  
		return
	
	# Detecta si está atascado
	if global_position.distance_to(last_position) < stuck_distance_threshold:
		stuck_timer += delta
		if stuck_timer > stuck_threshold:
			stuck_timer = 0.0
			_set_new_target()
			return
	else:
		stuck_timer = 0.0
	
	last_position = global_position
	
	# Movimiento hacia el destino
	var next_pos: Vector2 = navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_pos)
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	move_and_slide()
	_update_animation(direction)


func complete_dialogue()->void:
	dialogue_completed = true
	
func _give_waves_to_player() -> void:
	"""Otorga waves al jugador después de un diálogo exitoso"""
	if esta_saludando:
		return
	
	esta_saludando = true
	saludo_meme.show()
	saludo_meme.play("saludo")
	await saludo_meme.animation_finished
	saludo_meme.hide()
	esta_saludando = false
	
	var time_now = Time.get_ticks_msec() / 1000.0
	if time_now - ultimo_saludo >= cooldown_saludo and waves_to_give > 0:
		ultimo_saludo = time_now
		GameManager.add_wave()
		waves_to_give -= 1


func _on_player_near(body: Node2D) -> void:
	if body == self:
		player_nearby = true

func _on_player_away(body: Node2D) -> void:
	if body == self:
		player_nearby = false


func _on_dialogic_signal_executed(signal_name: String) -> void:
	if signal_name == "wave":
		_give_waves_to_player()
