extends CharacterBody3D

@export var HEALTH := 100
var current_health: int

var is_dead := false

const SPEED = 13.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

const AIR_ACCELERATION = 90.0

const MAX_BHOP_BONUS := 3.0        # o quanto de velocidade extra o bhop pode dar, no máximo
const BHOP_BONUS_STEP := 0.6       # quanto ganha por pulo encadeado com sucesso
const BHOP_CHAIN_WINDOW := 0.25    # janela (segundos) após pousar pra o próximo pulo "contar"
const BHOP_DECAY_SPEED := 4.0      # quão rápido perde o bônus se ficar andando no chão sem pular

var bhop_bonus := 0.0
var time_since_landed := 999.0
var was_on_floor := true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var health_component: HealthComponent = $Health

var gravity = 20

func _ready():
	health_component.set_max_health(HEALTH)
	current_health = health_component.current_health
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_die)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		head.rotate_x(-event.relative.y * SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	var just_landed := is_on_floor() and not was_on_floor
	if just_landed:
		time_since_landed = 0.0

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		if time_since_landed <= BHOP_CHAIN_WINDOW:
			bhop_bonus = minf(bhop_bonus + BHOP_BONUS_STEP, MAX_BHOP_BONUS)
		else:
			bhop_bonus = 0.0
		velocity.y = JUMP_VELOCITY

	var current_max_speed := SPEED + bhop_bonus

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_max_speed
			velocity.z = direction.z * current_max_speed
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		time_since_landed += delta
		if time_since_landed > BHOP_CHAIN_WINDOW:
			bhop_bonus = move_toward(bhop_bonus, 0.0, delta * BHOP_DECAY_SPEED)
	else:
		if direction:
			velocity.x += direction.x * AIR_ACCELERATION * delta
			velocity.z += direction.z * AIR_ACCELERATION * delta

			var horizontal_vel = Vector2(velocity.x, velocity.z)
			if horizontal_vel.length() > current_max_speed:
				horizontal_vel = horizontal_vel.normalized() * current_max_speed
				velocity.x = horizontal_vel.x
				velocity.z = horizontal_vel.y

	was_on_floor = is_on_floor()
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health_component.take_damage(amount)

func _on_health_changed(new_health: int, _max_health: int) -> void:
	current_health = new_health
	print("Player tomou dano! Vida: ", current_health)

func heal(amount: int) -> void:
	if is_dead:
		return
	health_component.heal(amount)

const GAME_OVER_SCENE := preload("res://scenes/player/gameover.tscn")

func _die() -> void:
	is_dead = true
	print("Player morreu!")

	var game_over := GAME_OVER_SCENE.instantiate()
	get_tree().current_scene.add_child(game_over)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
