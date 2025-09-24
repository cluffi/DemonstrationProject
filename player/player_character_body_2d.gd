class_name Player extends CharacterBody2D

const SPEED = 300.0 #скорость предвижения
const JUMP_VELOCITY = -400.0 #сила прыжка
const DASH_VELOCITY = 1500.0 #сила деша
const DASH_CALLDOWN = 0.5 #время отката деша
const DASH_TIME = 0.1 #продолжительность деша
const ATTACK_CALLDOWN = 1 #время отката атаки
const MULTIJUMP_TIME = 0.48 #время проигрывания анимации мультипрыжка

@export var direction = 0 #ось направленя (равна 1 при движении вправо и -1 при движении влево)
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") #ускорение свободного падения

#@onready var animation = $Animation #ссылка на ноду анимации
@onready var dash_timer = $DashTimer #ссылка на таймер деша
@onready var dash_calldown = $DashCalldown #таймер отката деша
@onready var attack_calldown = $AttackCalldown #таймер отката атаки
@onready var multijump_timer = $MultijumpTimer #таймер мультипрыжка

signal hit #сигнал атаки

var multijump_counter = 0 #счётчик прыжков в воздухе
var max_multijump = 1000 #максимальное количество воздушных прыжков
var multijump_flag = false #принимает значение "истина" во время мультипрыжка
var dash_flag = false #принимает значение "истина" во время деша
var dash_direction = 1 #направление деша

func gravitation(delta):
	'''
	действие гравитации на персонажа
	'''
	if not is_on_floor():
		velocity.y += gravity * delta

func move():
	'''
	движение персонажа (влево/вправо)
	'''
	if dash_flag: #деш блокирует перемещение
		return
	
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func jump():
	'''
	прыжок
	'''
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		multijump_counter = 0

func multijump():
	'''
	прыжок в воздухе
	'''
	if multijump_timer.time_left == 0:
		multijump_flag = false

	if Input.is_action_just_pressed("ui_accept") and not(is_on_floor()) and multijump_counter < max_multijump:
		velocity.y = JUMP_VELOCITY
		multijump_counter += 1
		multijump_flag = true
		multijump_timer.start()

func dash():
	'''
	деш
	'''
	if direction:
		dash_direction = direction
	
	if dash_flag:
		velocity.x = DASH_VELOCITY * dash_direction
		velocity.y = 0

	if Input.is_action_just_pressed("shift") and is_on_floor() and dash_calldown.time_left == 0:
		dash_timer.start()
		dash_flag = true
		return
	
	if dash_timer.time_left == 0 and dash_flag:
		dash_flag = false
		dash_calldown.start()

#func anmation():
	#'''
	#подключает анимации персонажу
	#'''
	#if direction:
		#animation.set_flip_h(-direction + 1)
	#
	#if velocity.y == 0 and velocity.x == 0:
		#animation.play("idle")
#
	#elif multijump_flag:
		#animation.play("multijump")
#
	#elif velocity.y < 0:
		#animation.play("jump_up")
#
	#elif velocity.y > 0:
		#animation.play("jump_down")
#
	#elif direction:
		#animation.play("run")
#
	#if dash_flag:
		#animation.play("dash")

func atack():
	if Input.is_action_just_pressed("fire_1") and attack_calldown.time_left == 0:
		attack_calldown.start()
		hit.emit()

func _ready():
	dash_timer.wait_time = DASH_TIME
	dash_calldown.wait_time = DASH_CALLDOWN
	attack_calldown.wait_time = ATTACK_CALLDOWN
	multijump_timer.wait_time = MULTIJUMP_TIME

func _physics_process(delta):
	
	gravitation(delta)
	move()
	jump()
	multijump()
	#anmation()
	dash()
	atack()
	
	move_and_slide()
