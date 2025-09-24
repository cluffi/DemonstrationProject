class_name ProceduralLevel

var height
var width
var rectangles = []
var block_size

func _init(_width, _height, _block_size):
	width = _width
	height = _height
	block_size = _block_size

func is_rectangle(x, y):
	for rect in rectangles:
		if rect.is_rectangle(x, y):
			return true
	return false

func generate_rectangle(width, height, x, y): #создаёт объект прямоугольника для левела plinst и добавляет его в список прямоугольников левела
	var rectinst = ProceduralRectangle.new(width, height, Vector2(x, y), block_size)
	rectangles.append(rectinst)
	return rectinst

func fill_level():
	#generate_rectangle(300, 100, 0, 100)
	generate_rectangle(400, 150, 0, 0)
	#
	#var r_width
	#var r_height
	#var min_width = 40 * block_size
	#var min_height = 40 * block_size
	#var r_pos_x
	#var r_pos_y
	#var last_pos_x = 0
	#var last_pos_y = 0
	#var last_width = min_width
	#var last_height = min_height
	#var is_valid_place = true
	#
	#r_width = randi_range(min_width, width / 2)
	#r_height = randi_range(min_height, height / 2)
	#r_pos_x = randi_range(width / 4, width - width / 2)
	#r_pos_y = randi_range(height / 4, height - height / 2)
	#generate_rectangle(r_width, r_height, r_pos_x, r_pos_y)
	#try_to_generate_rectangle(r_pos_x + r_width, r_pos_y, min_width, min_height)
	#try_to_generate_rectangle(r_pos_x - r_width, r_pos_y, min_width, min_height)
	#try_to_generate_rectangle(r_pos_x, r_pos_y + r_height, min_width, min_height)
	#try_to_generate_rectangle(r_pos_x, r_pos_y - r_height, min_width, min_height)
	#
#func try_to_generate_rectangle(pos_x, pos_y, min_width, min_height):
	#if pos_x + min_width < width and pos_y + min_height < height:
		#var r_width = randi_range(min_width, width - pos_x)
		#var r_height = randi_range(min_height, height - pos_y)
		#generate_rectangle(r_width, r_height, pos_x, pos_y)
