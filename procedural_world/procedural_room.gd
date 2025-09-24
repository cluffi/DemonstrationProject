class_name ProceduralRoom

var height #ширина в блоках
var width #высота в блоках
var position: Vector2i #позиця в пространстве (левый верхний угол), измеряемая в блоках

func _init(_height, _width, _position):
	width = _width
	height = _height
	position = _position
