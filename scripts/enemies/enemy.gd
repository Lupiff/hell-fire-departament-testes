extends CharacterBody3D

enum State { IDLE, WALK, SHOOT, DEATH }

@export var health = 100
@export var speed = 5
@export var distance_follow = 40
@export var distance_shoot = 3

var state := State.IDLE
var motion = Vector3.ZERO
var death = false
var shooting = false
var target = null

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

const GRAVITY = 20.0


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

	if target == null:
		target = get_node_or_null("../player")

	if target == null:
		push_warning("Inimigo não encontrou o jogador!")


func _physics_process(_delta: float) -> void:
	if target == null or death:
		return

	motion = Vector3.ZERO

	var distance := _get_distance_player()

	match state:

		State.IDLE:
			animated_sprite_3d.play("idle")

			if distance <= distance_follow:
				state = State.WALK


		State.WALK:
			animated_sprite_3d.play("walk")

			if distance <= distance_shoot:
				state = State.SHOOT
				return

			if distance > distance_follow:
				state = State.IDLE
				return

			var direction = target.global_position - global_position
			direction.y = 0
			motion = direction.normalized() * speed


		State.SHOOT:
			motion = Vector3.ZERO

			if distance > distance_shoot:
				state = State.WALK
				return

			if not shooting:
				_shoot()


		State.DEATH:
			motion = Vector3.ZERO


	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 20.0 * _delta
	else:
		velocity.y = 0


	# Movimento horizontal
	velocity.x = motion.x
	velocity.z = motion.z

	move_and_slide()


func _get_distance_player() -> float:
	return global_position.distance_to(target.global_position)


func _shoot() -> void:
	shooting = true
	animated_sprite_3d.play("shoot")

	await animated_sprite_3d.animation_finished

	animated_sprite_3d.play("idle")
	shooting = false
