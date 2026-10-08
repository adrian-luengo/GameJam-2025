extends CharacterBody2D

@export var jugador: CharacterBody2D

var conversation_name: String = "maker"
var player_nearby: bool = false

signal showArrow(show: bool)

func _ready() -> void:
	if jugador and jugador.has_node("wave_area"):
		var wave_area = jugador.get_node("wave_area")
		wave_area.body_entered.connect(_on_player_near)
		wave_area.body_exited.connect(_on_player_away)

func _process(_delta: float) -> void:
	if player_nearby:
		if Input.is_action_pressed("start_conversation") and GameManager.is_dialogue_on == false:
			GameManager.is_dialogue_on = true
			if Dialogic.timeline_exists(conversation_name):
				Dialogic.start_timeline(conversation_name)
				Dialogic.signal_event.connect(showArrowPopUp)
				await Dialogic.signal_event
				GameManager.is_dialogue_on = false
			return

func showArrowPopUp(string: String):
	if string == "show":
		emit_signal("showArrow", true)
	elif string == "hide":
		emit_signal("showArrow", false)
	else:
		print("THE F is this " + string)

func _on_player_near(body: Node2D) -> void:
	if body == self:
		player_nearby = true

func _on_player_away(body: Node2D) -> void:
	if body == self:
		player_nearby = false
