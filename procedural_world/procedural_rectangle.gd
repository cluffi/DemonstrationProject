class_name ProceduralRectangle

var height #ширина в тайлах
var width #высота в тайлах
var position: Vector2i #позиця в пространстве (центр фигуры), измеряемая в тайлах
var block_size #размер блока
var blocks = [] #карта блоков, из которых состоит прямоугольник, значение элемента карты определяет тип блока
#типы блоков: 0 - стена, 1 - пол, 2 - пустота(дыра в полу)
var rooms = [] #список всех комнат внури прямоугольника
const WALL = 0
const FLOOR = 1
const HOLE = 2

func _init(_width, _height, _position, _block_size):
	width = _width - _width % _block_size    #(округляются по модулю размера блока в меньшую сторону)
	height = _height - _height % _block_size #ширина и высота выравниваются по размеру блока
	position = _position
	block_size = _block_size
	
	for i in range(width / block_size): # начальная инициализация массива блоков
		blocks.append([])
		for j in range(height / block_size):
			blocks[i].append(0)

func generate_room(height, width, x, y):
	var roominst = ProceduralRoom.new(width, height, Vector2i(x, y))
	rooms.append(roominst)
	return roominst

func is_room(x, y):
	for roominst in rooms:
		if (x >= roominst.x and x < roominst.x + roominst.width)    and    (y >= roominst.y and y < roominst.y + roominst.height):
			return true
	return false

func draw_room(roominst: ProceduralRoom):
	for i in range(roominst.position.x, roominst.position.x + roominst.width):
		for j in range(roominst.position.y, roominst.position.y + roominst.height):
			blocks[i][j] = FLOOR

func is_rectangle(x, y): #проверка находится ли тайл с переданными координатами внутри прямоугольника
	if (x >= position.x and x < position.x + width)    and    (y >= position.y and y < position.y + height):
		return true
	return false

func fill_rectangle(mpinst: ProceduralMap):
	generate_walls(0.7, mpinst)
	draw_blocks(mpinst)

func draw_blocks(mpinst: ProceduralMap):
	for i in range(width / block_size):
		for j in range(height / block_size):
			make_block(mpinst, i, j)

func draw_rectangle(mpinst: ProceduralMap):
	for i in range(width / block_size):
		for j in range(height / block_size):
			make_block(mpinst, i, j)

func generate_walls(wall_density, mpinst: ProceduralMap): #заполняет прямоугольник стенами и пустотами
	wall_density = clamp(wall_density, 0, 1) #ограничиваем wall_density
	var not_found = true
	
	for i in range(width / block_size): #обходим все блоки по вертикали, начиная с левого верхнего края
		for j in range(height / block_size):
			blocks[i][j] = FLOOR #временно устанавливаем текщий блок в состояние пол
			
			if i - 1 >= 0 and j - 1 >= 0 and i != width / block_size - 1: #если блок не находится на границах прямоугольника, короме нижней
				
				if blocks[i - 1][j] == FLOOR: #если слева нет стены
					not_found = true
					
					for k in range(i - 1, -1, -1): #проверяем, есть ли слева блок пола, соседствующий с блоком пола этажа выше
						if blocks[k][j] == WALL: #если встретилась стена выходим из цикла
							break
						
						if blocks[k][j - 1] == FLOOR: #если такой блок нашёлся
							if randf() < wall_density: #случайным образом выбираем блок стены или пола, основываясь на параметре плотности стен
								blocks[i][j] = WALL
							else:
								blocks[i][j] = FLOOR
							
							not_found = false #устанавливаем флаг и выходим из цикла
							break
							
					if not_found:
						blocks[i][j] = FLOOR
						
				else: #слева есть стена
					if randf() < wall_density:
						blocks[i][j] = WALL
					else:
						blocks[i][j] = FLOOR
						
			elif i == 0: #если блок находится на левой границе прямоугольника
				if randf() < wall_density:
					blocks[i][j] = WALL
				else:
					blocks[i][j] = FLOOR
					
			elif j == 0: #если блок находится на верхней границе прямоугольника
				not_found = true
				
				for k in range(i - 1, -1, -1): #проверяем, есть ли слева блок пола, соседствующий с блоком пола этажа ниже
					if blocks[k][j] == WALL: #если встретилась стена выходим из цикла
						break
						
					if blocks[k][j + 1] == FLOOR: #если такой блок нашёлся
						if randf() < wall_density: #случайным образом выбираем блок стены или пола
							blocks[i][j] = WALL
						else:
							blocks[i][j] = FLOOR
						
					not_found = false #устанавливаем флаг и выходим из цикла
					break
					
				if not_found:
					blocks[i][j] = FLOOR
						
			elif i == width / block_size - 1: #если блок находится на правой границе прямоугольника
				if blocks[i][j - 1] == FLOOR: #если сверху нет стены
					not_found = true
					
					for k in range(i - 1, -1, -1): #проверяем, является ли полость на этаже выше изолированной
						if blocks[k][j - 1] == WALL: #если встретилась стена выходим из цикла
							break
							
						if j - 2 >= 0: #если проверяемая полость не находится на верхнем этаже
							if blocks[k][j - 2] == FLOOR: #если блок пола, соедствующий с другим блоком пола на этаже выше нашёлся полость не изолированна
								if randf() < wall_density: #случайным образом выбираем блок стены или пола
									blocks[i][j] = WALL
								else:
									blocks[i][j] = FLOOR
								not_found = false
								break
								
						if blocks[k][j] == FLOOR: #если блок пола, соедствующий с другим блоком пола на этаже ниже нашёлся полость не изолированна
							if randf() < wall_density: #случайным образом выбираем блок стены или пола
								blocks[i][j] = WALL
							else:
								blocks[i][j] = FLOOR
							not_found = false
							break
						
					if not_found:
						blocks[i][j] = FLOOR
							
					else: #если сверху есть стена, но её нет слева
						if randf() < wall_density: #случайным образом выбираем блок стены или пола
							blocks[i][j] = WALL
						else:
							blocks[i][j] = FLOOR
							
				else: #сверху есть стена
					if blocks[i - 1][j] == FLOOR: #если слева нет стены
						not_found = true
						
						for k in range(i - 1, -1, -1): #проверяем, есть ли слева блок пола, соседствующий с блоком пола этажа выше
							if blocks[k][j] == WALL: #если встретилась стена выходим из цикла
								break
								
							if blocks[k][j - 1] == FLOOR: #если такой блок нашёлся
								if randf() < wall_density: #случайным образом выбираем блок стены или пола
									blocks[i][j] = WALL
								else:
									blocks[i][j] = FLOOR
									
								not_found = false #устанавливаем флаг и выходим из цикла
								break
							
						if not_found:
							blocks[i][j] = FLOOR
						
					else: #слева есть стена
						blocks[i][j] = WALL
						
	create_rooms(mpinst)
	generate_big_rooms(0.5)
	denoise()
	clear_unreachable()
	break_some_walls(0.5)
	draw_blocks(mpinst)

func denoise():
	print("denoise")
	var res
	var deleted = 0
	for i in range(width / block_size):
		for j in range(height / block_size):
			res = 0
			if blocks[i][j] == WALL:
				if i + 1 < width / block_size:
					if blocks[i + 1][j] == WALL:
						res += 1
				if i - 1 > 0:
					if blocks[i - 1][j] == WALL:
						res += 1
				if j + 1 < height / block_size:
					if blocks[i][j + 1] == WALL:
						res += 1
				if j - 1 > 0:
					if blocks[i][j - 1] == WALL:
						res += 1
				if res == 0:
					blocks[i][j] = FLOOR
	return deleted

func create_rooms(mpinst: ProceduralMap):
	mark_unreachable()
	
	var r_width
	var r_height
	var max_width = 5
	var max_height = 5
	
	for x in range(width / block_size / 2, width / block_size - max_width + 1):
		for y in range(height / block_size / 2, height / block_size - max_height + 1):
			r_width = randi_range(2, max_width)
			r_height = randi_range(2, max_height)
			if try_generate_room(r_width, r_height, x, y):
				draw_blocks(mpinst)
				clear_unreachable()
				mark_unreachable()
				
		for y in range(height / block_size / 2, -1, -1):
			r_width = randi_range(2, max_width)
			r_height = randi_range(2, max_height)
			if try_generate_room(r_width, r_height, x, y):
				draw_blocks(mpinst)
				clear_unreachable()
				mark_unreachable()
	
	for x in range(width / block_size / 2, -1, -1):
		for y in range(height / block_size / 2, height / block_size - max_height + 1):
			r_width = randi_range(2, max_width)
			r_height = randi_range(2, max_height)
			if try_generate_room(r_width, r_height, x, y):
				draw_blocks(mpinst)
				clear_unreachable()
				mark_unreachable()
				
		for y in range(height / block_size / 2, -1, -1):
			r_width = randi_range(2, max_width)
			r_height = randi_range(2, max_height)
			if try_generate_room(r_width, r_height, x, y):
				draw_blocks(mpinst)
				clear_unreachable()
				mark_unreachable()
	print("generated")

func try_generate_room(r_width, r_height, x, y):
	var checked_markers = []
	var roominst
	
	for i in range(x, x + r_width):
		for j in range(y, y + r_height):
			if blocks[i][j] not in checked_markers and blocks[i][j] != WALL:
				checked_markers.append(blocks[i][j])
				
				if len(checked_markers) > 1:
					roominst = generate_room(r_width, r_height, x, y)
					draw_room(roominst)
					return true
	return false

func generate_big_rooms(density):
	var r_width
	var r_height
	var roominst
	var max_width = 5 #max(width / block_size / 100, 2)
	var max_height = 3 #max(height / block_size / 100, 2)
	var r_pos_x
	var r_pos_y
	var max_rooms_amount = 4 #width * height / max_width / max_height * density
	var rooms_amount = randi_range(1, max_rooms_amount)
	
	for i in range(rooms_amount):
		r_width = randi_range(2, max_width)
		r_height = randi_range(2, max_height)
		r_pos_x = randi_range(0, width / block_size - max_width)
		r_pos_y = randi_range(0, height / block_size - max_height)
		
		roominst = generate_room(r_width, r_height, r_pos_x, r_pos_y)
		draw_room(roominst)

func mark_unreachable(): #помечает несвязанные части пустот
	var start_block
	var marker = -1 #используется для пометки достижимых блоков
	var all_voids = [] #список векторов, хранящий в себе координаты векторов для работы с рекурентными функциями
	var markers = [] #список использованных маркеров
	var isolated = [] #все изолированные формации
	
	while true:
		all_voids = [] #список пустот
		for i in range(width / block_size):
			for j in range(height / block_size):
				if blocks[i][j] == FLOOR: #все блоки типа FLOOR добавляются в список all_voids в виде векторов, хранящих их позиции
					all_voids.append(Vector2i(i, j))
		
		if len(all_voids) <= 0: #если таких блоков нет, то выходим из цикла
			break
		
		start_block = all_voids[randi_range(0, len(all_voids) - 1)] #берём случайный блок как отправную точку
		mark_isolated(start_block, marker)
		
		markers.append(marker)
		isolated.append([])
		marker -= 1
	
	if len(markers) <= 0:
		return

func clear_unreachable():
	for i in range(width / block_size): #обходим все блоки по вертикали, начиная с левого верхнего края
		for j in range(height / block_size):
			if blocks[i][j] != WALL:
				blocks[i][j] = FLOOR

func mark_isolated(start_block, marker):
	var next = [start_block]
	for i in next:
		if blocks[i.x][i.y] == FLOOR:
			blocks[i.x][i.y] = marker
			if i.x + 1 < width / block_size:
				next.append(Vector2i(i.x + 1, i.y))
			if i.y + 1 < height / block_size:
				next.append(Vector2i(i.x, i.y + 1))
			if i.x - 1 >= 0:
				next.append(Vector2i(i.x - 1, i.y))
			if i.y - 1 >= 0:
				next.append(Vector2i(i.x, i.y - 1))

func break_some_walls(holes_density):
	var not_found
	var last
	
	for i in range(width / block_size):
		for j in range(height / block_size):
			if j != height / block_size - 1 and blocks[i][j] == FLOOR: #если блок не находится на нижей границе прямоугольника и явлеятся блоком пола
				if blocks[i][j + 1] == FLOOR: #если снизу блок пола
					not_found = true
					for k in range(i, -1, -1): #проверяем, есть ли слева проходы на этаж ниже
						if blocks[k][j] == WALL or blocks[k][j + 1] == WALL: #если встретили стену на текущем этаже или этаже ниже выходим из цикла
							break
						if blocks[k][j] == HOLE: #если нашёлся проход сбрасываем флаг и выходим из цикла
							not_found = false
							break
					last = true
					if i + 1 != width / block_size: #если блок не находится на правой границе прямоугольника
						if blocks[i + 1][j + 1] == FLOOR and blocks[i + 1][j] != WALL: #если справа на текущем этаже нет стены, а на этаже ниже справа есть блок пола
							last = false
							
					if not_found and last:
						blocks[i][j] = HOLE
					if not_found:
						if randf() < holes_density: #случайным образом выбираем, делать ли проход на этаж ниже
							blocks[i][j] = HOLE
							
						#else: #если справа нет стены
							#if randf() < holes_density: #случайным образом выбираем, делать ли проход на этаж ниже
									#blocks[i][j] = HOLE

func make_block(pminst: ProceduralMap, block_index_x, block_index_y):
	var block_x = position.x + block_index_x * block_size
	var block_y = position.y + block_index_y * block_size
	
	for i in range(block_size):
		for j in range(block_size):
			#if blocks[block_index_x][block_index_y] < 0:
				#pminst.map[block_x + i][block_y + j] = Vector2i(abs(blocks[block_index_x][block_index_y]) % 10, (abs(blocks[block_index_x][block_index_y]) % 2))
			#else:
				#match blocks[block_index_x][block_index_y]:
					#0:
						#pminst.map[block_x + i][block_y + j] = Vector2i(0, 0) #LAND_MIDDLE
					#1:
						#if j == block_size - 1:
							#pminst.map[block_x + i][block_y + j] = Vector2i(1, 0) #LAND_MIDDLE
						#else:
							#pminst.map[block_x + i][block_y + j] = Vector2i(0, 0) #EMPTY
					#_:
						#pminst.map[block_x + i][block_y + j] = Vector2i(0, 0) #EMPTY

			match blocks[block_index_x][block_index_y]:
				WALL:
					pminst.map[block_x + i][block_y + j] = pminst.LAND_MIDDLE
				FLOOR:
					if j == block_size - 1:
						pminst.map[block_x + i][block_y + j] = pminst.LAND_MIDDLE
					else:
						pminst.map[block_x + i][block_y + j] = pminst.EMPTY
				_:
					pminst.map[block_x + i][block_y + j] = pminst.EMPTY
