extends Node2D

const BLUE_COLOR = Vector2i(0, 0)
const PINK_COLOR = Vector2i(1, 0)
const CHUNCK_SIZE = 500

var thread: Thread

@onready var label = $"../Label"

const TILE_SET = preload("res://procedural_world/procedural_world1.tres")

var player: Player
var pminst: ProceduralMap
var plinst: ProceduralLevel
var tminst: TileMapLayer
var world_x = 400
var world_y = 150
var status

func _ready():
	world_generator(world_x, world_y)

func world_generator(x, y):
	pminst = ProceduralMap.new(x, y)
	plinst = ProceduralLevel.new(x, y, 10)
	
	generate_level(x, y)
	show_generated(x, y)

func show_generated(x, y):
	var map: Array[Vector2i] = []
	var len
	
	tminst = TileMapLayer.new()
	tminst.tile_set = TILE_SET
	
	for i in range(x):
		for j in range(y):
			tminst.set_cell(Vector2i(i, j), 1, pminst.map[i][j])
			if pminst.map[i][j] != pminst.EMPTY:
				map.append(Vector2i(i, j))
				
	#tminst.set_cells_terrain_connect(map, 0, 0, true)
	
	len = len(map)
	for i in range(int(len / CHUNCK_SIZE)):
		status = int(i / float(len / CHUNCK_SIZE - 1) * 100)
		tminst.set_cells_terrain_connect(map.slice(i * CHUNCK_SIZE, (i + 1) * CHUNCK_SIZE), 1, 0, true)
		await get_tree().process_frame
	print("mapping...")
	
	if len % CHUNCK_SIZE != 0:
		tminst.set_cells_terrain_connect(map.slice(int(len / CHUNCK_SIZE)), 1, 0, true)
	
	var t1 = Time.get_ticks_msec()
	add_child(tminst)
	var t2 = Time.get_ticks_msec()
	print("задержка: ", t2 - t1, " мс")
	
#func show_generated(x: int, y: int, pminst: ProceduralMap) -> void:
	#if tminst == null:
		#tminst = TileMapLayer.new()
		#tminst.tile_set = TILE_SET
		#add_child(tminst)
	#else:
		#tminst.clear()
#
	#var non_empty_cells: Array[Vector2i] = []
	#for i in range(x):
		#for j in range(y):
			#tminst.set_cell(Vector2i(i, j), 0, pminst.map[i][j])
			#if pminst.map[i][j] != pminst.EMPTY:
				#non_empty_cells.append(Vector2i(i, j))
#
	#var total := non_empty_cells.size()
	#if total == 0:
		#return
#
	#var chunk_count := int(total / CHUNCK_SIZE)
#
	#if chunk_count > 0:
		#var denom = max(chunk_count - 1, 1)
		#for i in range(chunk_count):
			#var start := i * CHUNCK_SIZE
			#var end = min(start + CHUNCK_SIZE, total)
			#if start >= end:
				#continue
			#var slice := non_empty_cells.slice(start, end)
			#tminst.set_cells_terrain_connect(slice, 0, 0, true)
			#await get_tree().process_frame
			#status = int(i / float(denom) * 100)
#
	#var remainder_start := chunk_count * CHUNCK_SIZE
	#if remainder_start < total:
		#var tail := non_empty_cells.slice(remainder_start, total)
		#if tail.size() > 0:
			#tminst.set_cells_terrain_connect(tail, 0, 0, true)
#
	#print("mapping done, non-empty cells:", total)



func generate_level(x, y):
	print("generating...")
	
	plinst.fill_level()
	
	for i in range(x):
		for j in range(y):
			if plinst.is_rectangle(i, j):
				pminst.map[i][j] = pminst.EMPTY
	
	for rect in plinst.rectangles:
		thread = Thread.new()
		thread.start(rect.fill_rectangle.bind(pminst))
		thread.wait_to_finish()
		#rect.fill_rectangle(pminst)

func _process(delta):
	label.text = "generating: " + str(status) + "%"
