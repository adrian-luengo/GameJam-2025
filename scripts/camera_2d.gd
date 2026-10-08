extends Camera2D

@onready var camera: Camera2D = $Camera2D

func _ready():
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1280  # ancho del mapa
	camera.limit_bottom = 720  # alto del mapa
