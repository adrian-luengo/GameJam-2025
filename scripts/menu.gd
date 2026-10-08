extends Control


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_jugar_pressed() -> void:
	SceneTransition.transition_to("res://escenas/tutorial.tscn")


func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/MenuOpc.tscn")


func _on_creditos_pressed() -> void:
	pass # Cuando tengamos escena de creditos
