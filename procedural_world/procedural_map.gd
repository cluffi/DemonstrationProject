class_name ProceduralMap

#const LAND_MIDDLE = Vector2i(3, 1)
#const EMPTY = Vector2i(5, 2)

const LAND_MIDDLE = Vector2i(2, 1)
const EMPTY = Vector2i(18, 0)

var map = []

func _init(x, y):
	for i in range(x):
		map.append([])
		for j in range(y):
			map[i].append(LAND_MIDDLE)
