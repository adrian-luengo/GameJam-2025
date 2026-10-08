extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var shader_material: ShaderMaterial = $ColorRect.material as ShaderMaterial

func transition_to(scene_path: String):
	
	shader_material.set_shader_parameter("progress", 0.0)
	await tween_property(shader_material, "shader_parameter/progress", 1.0, 0.7)
	
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame 
	await tween_property(shader_material, "shader_parameter/progress", 0.0, 0.7)
	
func tween_property(target, property_path, final_value, duration):
	
	var t = create_tween()
	t.tween_property(target, property_path, final_value, duration)
	await t.finished
