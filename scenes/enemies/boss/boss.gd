extends CharacterBody3D
class_name Boss

@export var max_health: int = 100
@export var phase1_damage: int = 8
@export var phase1_fire_rate: float = 1.0
@export var phase1_range: float = 15.0
@export var detection_range: float = 20.0     # só persegue dentro desse alcance
@export var move_speed: float = 4.0
@export var close_range: float = 5.0          # distância "bem perto" pra disparos em sequência
@export var prediction_lead: float = 0.15   # 0 = sem previsão, 1 = previsão total do tempo de windup, serve pra ele n ficar burro na hr de atirar na teoria

const SHOOT_DAMAGE_FRAME := 1
const GRAVITY := 20.0

var current_phase := 1
var fire_cooldown := 0.0
var is_firing := false
var player: Node3D

@onready var health_component: HealthComponent = $Health
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var muzzle: Marker3D = $Muzzle
@onready var ray_cast: RayCast3D = $RayCast3D

func _ready() -> void:
	health_component.set_max_health(max_health)
	health_component.health_changed.connect(_on_health_changed)
	player = get_tree().get_first_node_in_group("player")
	sprite.play("idle")
	ray_cast.add_exception(self)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	if player == null:
		move_and_slide()
		return

	fire_cooldown -= delta

	match current_phase:
		1:
			_phase1_behavior(delta)

	move_and_slide()

func _get_distance_to_player() -> float:
	ray_cast.target_position = ray_cast.to_local(player.global_position)
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		var body := ray_cast.get_collider()
		if body == player:
			return global_position.distance_to(player.global_position)
		return INF   # tem parede no meio

	return global_position.distance_to(player.global_position)

func _phase1_behavior(_delta: float) -> void:
	var dist := _get_distance_to_player()

	if dist > detection_range:
		velocity.x = 0.0
		velocity.z = 0.0
		sprite.play("idle")
		return

	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

	if is_firing:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	# se não tá "bem perto", continua andando na direção do player mesmo entre tiros
	if dist > close_range:
		var direction := (player.global_position - global_position)
		direction.y = 0
		direction = direction.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	if dist <= phase1_range and fire_cooldown <= 0.0:
		_fire_pistol()
		fire_cooldown = 1.0 / phase1_fire_rate

func _fire_pistol() -> void:
	is_firing = true
	sprite.play(&"shoot")

	var aim_from := muzzle.global_position
	var aim_target := player.global_position

	await _wait_for_frame(SHOOT_DAMAGE_FRAME)

	if current_phase == 1:
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(aim_from, aim_target)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result and result.collider.has_method("take_damage"):
			result.collider.take_damage(phase1_damage)

	if sprite.animation == &"shoot":
		await sprite.animation_finished

	is_firing = false
	sprite.play(&"idle")   # <- garante que volta pro idle depois de atirar

	if sprite.animation == &"shoot":
		await sprite.animation_finished   # só libera o movimento quando a animação acabar de verdade

	is_firing = false
func _wait_for_frame(target_frame: int) -> void:
	while sprite.animation == &"shoot" and sprite.frame < target_frame:
		await sprite.frame_changed

func take_damage(amount: int) -> void:
	health_component.take_damage(amount)

func _on_health_changed(current_health: int, max_health_value: int) -> void:
	var ratio := float(current_health) / max_health_value
	if current_phase == 1 and ratio <= 0.5:
		current_phase = 0
		print("Boss chegou em 50% — Fase 2 ainda será implementada numa próxima sessão.")
