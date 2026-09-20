extends CharacterBody3D

@export var HEALTH := 100
var current_health: int

var is_dead := false

const SPEED = 10.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

const AIR_ACCELERATION = 90.0   # quão rápido você consegue MUDAR de direção no ar
const AIR_CAP = 16.0            # velocidade máxima no ar (permite ficar um pouco acima do SPEED normal, tipo bhop)

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
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		# No chão: resposta instantânea, igual já era
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		# No ar: aceleração suave, preserva momentum
		if direction:
			velocity.x += direction.x * AIR_ACCELERATION * delta
			velocity.z += direction.z * AIR_ACCELERATION * delta

			# Limita a velocidade horizontal máxima no ar
			var horizontal_vel = Vector2(velocity.x, velocity.z)
			if horizontal_vel.length() > AIR_CAP:
				horizontal_vel = horizontal_vel.normalized() * AIR_CAP
				velocity.x = horizontal_vel.x
				velocity.z = horizontal_vel.y

	move_and_slide()
	
func take_damage(amount: int) -> void:
	if is_dead:
		return
	health_component.take_damage(amount)

func _on_health_changed(new_health: int, _max_health: int) -> void:
	current_health = new_health
	print("Player tomou dano! Vida: ", current_health)

func _die() -> void:
	is_dead = true
	print("Player morreu!")
	set_physics_process(false)      # trava movimento do player
	# aqui depois entra: mostrar tela de game over, pausar o jogo, etc.
