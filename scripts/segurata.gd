extends CharacterBody2D

@export var target: Node2D 
@export var detection_range: float = 100.0
@export var speed = 35
@export var acceleration = 7

@export var navigation_agent_2d: NavigationAgent2D
@export var spawnPos: Marker2D
@export var waves_to_be_safe: int = 2

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_chasing: bool = false

func _process(delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		velocity = velocity.lerp(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		var next_pos: Vector2 = navigation_agent_2d.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_pos)
		_update_animation(direction)
		return 

	var next_pos: Vector2 = navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_pos)
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	move_and_slide()
	_update_animation(direction)

func _update_animation(dir: Vector2) -> void:
	if dir.length() < 0.1:
		anim_sprite.play("idle_back")
		return
	if is_chasing == false:
		anim_sprite.play("idle_back")
		return
	
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim_sprite.play("derecha")
		else:
			anim_sprite.play("izquierda") 
	else:
		if dir.y > 0:
			anim_sprite.play("abajo")
		else:
			anim_sprite.play("arriba")

			

func _on_timer_timeout() -> void:
	if target == null:
		return
	if GameManager.is_dialogue_on:
		velocity = Vector2.ZERO
		return
	if is_in_group("enemigo"):
		
		if GameManager.current_wave >= waves_to_be_safe:
			navigation_agent_2d.target_position = spawnPos.global_position
			is_chasing = false
			return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	if distance_to_target < detection_range:
		navigation_agent_2d.target_position = target.global_position
		is_chasing = true
	else:
		navigation_agent_2d.target_position = spawnPos.global_position
		is_chasing = false

func reset_position() -> void:

	global_position = spawnPos.global_position
	navigation_agent_2d.target_position = spawnPos.global_position
	is_chasing = false
	velocity = Vector2.ZERO
	anim_sprite.stop() 
