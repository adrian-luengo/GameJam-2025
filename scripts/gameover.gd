extends CanvasLayer

func _on_yes_pressed() -> void:
	get_tree().paused = false  
	GameManager.reset_game_data()
	get_tree().reload_current_scene()

func _on_no_pressed() -> void:
	get_tree().quit()
