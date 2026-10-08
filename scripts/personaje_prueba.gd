extends CharacterBody2D

@export var speed: float = 50

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death: AudioStreamPlayer2D = $death
@onready var wave_area: Area2D = $wave_area
@onready var saludo_meme: AnimatedSprite2D = $SaludoMeme
@export var spawn : Marker2D

@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer
@export var regular_bgm = AudioStream
@export var hurry_bgm = AudioStream
@onready var music_timer: Timer = Timer.new()

const WAVING_HAND = preload("uid://clwy318gtiyom")
var wave_hand:Node2D
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	saludo_meme.hide()
	
	music_timer.wait_time = GameManager.max_time_sec - 60
	music_timer.one_shot = false
	music_timer.autostart = true
	add_child(music_timer)
	
	bgm_player.stream = regular_bgm
	bgm_player.play()
	
	music_timer.connect("timeout", Callable(self, "_on_one_min_left"))

func _on_one_min_left() -> void:
	bgm_player.stream = hurry_bgm
	bgm_player.play()

func wave_action():
	# El player muestra el saludo
	if not GameManager.is_dialogue_on:
		saludo_meme.show()
		saludo_meme.play("saludo")
		await saludo_meme.animation_finished
		saludo_meme.hide()
		# NPCs cercanos devuelven el saludo
		for body in wave_area.get_overlapping_bodies():
			if body.has_method("wave_back"):
				body.wave_back()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://escenas/Menu.tscn")
		return 
	if GameManager.is_dialogue_on == true:
		return
	if event.is_action_pressed("wave"):
		wave_action()

func _physics_process(delta):
	if GameManager.is_dialogue_on == true:
		return
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("arriba"):
		direction.y -= 1
		animated_sprite_2d.play("arriba")
	elif Input.is_action_pressed("abajo"):
		direction.y += 1
		animated_sprite_2d.play("abajo")
	elif Input.is_action_pressed("derecha"):
		direction.x += 1
		animated_sprite_2d.play("derecha")
	elif Input.is_action_pressed("izquierda"):
		direction.x -= 1
		animated_sprite_2d.play("izquierda")
	
	direction = direction.normalized()
	
	if direction != Vector2.ZERO:
		move_and_collide(direction * speed * delta)
	else:
		animated_sprite_2d.play("idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if GameManager.is_dialogue_on == false:
		if body.is_in_group("conserje"):
			if Dialogic.timeline_exists("atrapado_conserje"):
				Dialogic.start_timeline("atrapado_conserje")
				await Dialogic.timeline_ended
			
			GameManager.set_dialogue_on(false)
			global_position = spawn.global_position  # ← AQUÍ
			if body.has_method("reset_position"):
				body.reset_position()
		
		elif body.is_in_group("enemigo"):
			if Dialogic.timeline_exists("security"):
				Dialogic.start_timeline("security")
				await Dialogic.timeline_ended
				print("timeline_ended")  # ← ESTO DEBERÍA PRINTEAR
			else:
				print("Timeline 'security' no existe")
			
			# ← FUERZA EL RESET aquí sin esperar
			GameManager.set_dialogue_on(false)
			if not Dialogic.VAR.Events.superado_security:
				global_position = spawn.global_position 
				print("global position = spawn")
			if body.has_method("reset_position"):
				body.reset_position()
