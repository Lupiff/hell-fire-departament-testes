extends CharacterBody3D
class_name Enemy

enum State { IDLE, WALK, ATTACK, DEATH }

@export var data: EnemyData
@export var health_pickup_scene: PackedScene
@export var ammo_pickup_scene: PackedScene

var current_health: int
var state := State.IDLE
var motion := Vector3.ZERO
var attacking := false
var attack_timer := 0.0
var target: Node3D

const GRAVITY := 20.0
const HEALTH_BAR_WIDTH := 1.1

var ai_tick_timer := 0.0
const AI_TICK_RATE := 0.1
const CULL_DISTANCE := 40.0

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var health_component: HealthComponent = $Health
@onready var health_bar: Node3D = $HealthBar
@onready var health_fill: MeshInstance3D = $HealthBar/HealthBarFill


func _ready() -> void:
	if not data:
		push_error("Enemy sem EnemyData atribuído!")
		return

	health_component.set_max_health(data.max_health)
	current_health = health_component.current_health
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_die)
	_update_health_bar(current_health, data.max_health)
	animated_sprite_3d.sprite_frames = data.sprite_variants.pick_random()
	animated_sprite_3d.play("idle")

	target = get_tree().get_first_node_in_group("player")
	if target == null:
		push_warning("Inimigo não encontrou o jogador!")

	ray_cast_3d.add_exception(self)


func _physics_process(delta: float) -> void:
	if target == null or state == State.DEATH:
		return
		
	if "is_dead" in target and target.is_dead:
		motion = Vector3.ZERO
		animated_sprite_3d.play("idle")
		return

	if global_position.distance_to(target.global_position) > CULL_DISTANCE:
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	attack_timer -= delta

	ai_tick_timer -= delta
	if ai_tick_timer <= 0.0:
		ai_tick_timer = AI_TICK_RATE
		_update_ai(delta)

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	velocity.x = motion.x
	velocity.z = motion.z
	move_and_slide()

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		health_bar.look_at(camera.global_position, Vector3.UP, true)


func _update_ai(_delta: float) -> void:
	var distance := _get_distance_to_player()

	match state:
		State.IDLE:
			motion = Vector3.ZERO
			animated_sprite_3d.play("idle")
			if distance <= data.detection_range:
				state = State.WALK

		State.WALK:
			animated_sprite_3d.play("walk")

			if distance <= data.attack_range:
				state = State.ATTACK
				return

			if distance > data.detection_range:
				state = State.IDLE
				motion = Vector3.ZERO
				return

			var direction := target.global_position - global_position
			direction.y = 0
			motion = direction.normalized() * data.move_speed

		State.ATTACK:
			motion = Vector3.ZERO

			if distance > data.attack_range * 1.2:
				state = State.WALK
				return

			if not attacking and attack_timer <= 0.0:
				_shoot()
				attack_timer = data.attack_cooldown


func _get_distance_to_player() -> float:
	ray_cast_3d.target_position = ray_cast_3d.to_local(target.global_position)
	ray_cast_3d.force_raycast_update()

	if ray_cast_3d.is_colliding():
		var body := ray_cast_3d.get_collider()
		if body == target:
			return global_position.distance_to(target.global_position)
		return INF

	return global_position.distance_to(target.global_position)


func _shoot() -> void:
	attacking = true
	animated_sprite_3d.play("shoot")

	await animated_sprite_3d.animation_finished

	if data.attack_type == "melee":
		if target and target.has_method("take_damage"):
			if global_position.distance_to(target.global_position) <= data.attack_range * 1.3:
				target.take_damage(data.damage)
	elif data.attack_type == "ranged":
		_fire_projectile()

	animated_sprite_3d.play("idle")
	attacking = false


func _fire_projectile() -> void:
	pass


func take_damage(amount: int) -> void:
	if state == State.DEATH:
		return
	health_component.take_damage(amount)

func _on_health_changed(new_health: int, max_health: int) -> void:
	current_health = new_health
	_update_health_bar(current_health, max_health)
	print("Inimigo tomou dano! Vida: ", current_health, " / ", max_health)

func _update_health_bar(current: int, maximum: int) -> void:
	var ratio := clampf(float(current) / maximum, 0.0, 1.0)
	health_fill.scale.x = ratio
	health_fill.position.x = -HEALTH_BAR_WIDTH * (1.0 - ratio) * 0.5


func _die() -> void:
	state = State.DEATH
	animated_sprite_3d.play("death")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	_try_drop_pickup()
	await animated_sprite_3d.animation_finished
	queue_free()

func _try_drop_pickup() -> void:
	if data.possible_drops.is_empty():
		return
	if randf() > data.drop_chance:
		return

	var chosen_data: PickupData = data.possible_drops.pick_random()
	var scene: PackedScene = health_pickup_scene if chosen_data.type == "health" else ammo_pickup_scene

	if not scene:
		return

	var pickup := scene.instantiate()
	pickup.data = chosen_data
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = _get_floor_position()

func _get_floor_position() -> Vector3:
	var space_state := get_world_3d().direct_space_state
	var from := global_position
	var to := global_position + Vector3.DOWN * 5.0   # procura o chão até 5m abaixo

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result := space_state.intersect_ray(query)
	if result:
		return result.position + Vector3(0, 0.10, 0) 

	return global_position   # fallback: se não achar chão, usa a posição original
