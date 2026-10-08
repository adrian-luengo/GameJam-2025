extends Camera2D

@export var yAxis: float

var xAxisLimitRight: float = 231.666
var xAxisLimitLeft: float = 120.833

func _process(_delta: float) -> void:
	if get_parent().global_position.x <= xAxisLimitRight and get_parent().global_position.x > xAxisLimitLeft:
		global_position.x = get_parent().global_position.x
	elif get_parent().global_position.x > xAxisLimitRight:
		global_position.x = xAxisLimitRight
	else:
		global_position.x = xAxisLimitLeft
	global_position.y = yAxis
