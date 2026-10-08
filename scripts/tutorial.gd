extends Node2D

@export var xRectificationWhenNotMet: float = 340.0
@export var popUpControlNode: Control

func _on_transition_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if Dialogic.VAR.Events.talked_to_maker:
			GameManager.start_timer()
			SceneTransition.transition_to("res://escenas/CIC.tscn")
		else:
			if Dialogic.timeline_exists("makerNotMet"):
				Dialogic.start_timeline("makerNotMet")
				await Dialogic.timeline_ended
				GameManager.is_dialogue_on = false
				body.global_position.x = xRectificationWhenNotMet
			return


func _on_maker_show_arrow(showPopUp: bool) -> void:
	var popUpIcon: Node2D = popUpControlNode.get_node("ArrowSignal")
	if showPopUp:
		popUpIcon.show()
	else:
		popUpIcon.hide()
