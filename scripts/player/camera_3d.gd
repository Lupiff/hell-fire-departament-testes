extends Camera3D

const BASE_FOV := 75.0
const HITSCAN_RANGE := 1000.0

@export var weapons: Array[WeaponData] = []

var base_weapon_scale: Vector3
var current_index := 0
var current_ammo := 0
var fire_cooldown := 0.0
var reload_cooldown := 0.0
var is_reloading := false

@onready var sprite: AnimatedSprite3D = $WeaponSprite3D

func _ready() -> void:
	base_weapon_scale = sprite.scale
	fov = BASE_FOV
	sprite.animation_finished.connect(_on_animation_finished)
	if not weapons.is_empty():
		equip_weapon(0)

func _process(delta: float) -> void:
	if weapons.is_empty():
		return

	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	if is_reloading:
		reload_cooldown -= delta
		if reload_cooldown <= 0.0:
			_finish_reload()
		return

	var data := weapons[current_index]
	if Input.is_action_pressed("shoot") and fire_cooldown <= 0.0:
		if data.is_automatic or Input.is_action_just_pressed("shoot"):
			fire()
			fire_cooldown = 1.0 / maxf(data.fire_rate, 0.01)

func apply_fov(new_fov: float) -> void:
	fov = new_fov
	var scale_factor := tan(deg_to_rad(new_fov) / 2.0) / tan(deg_to_rad(BASE_FOV) / 2.0)
	sprite.scale = base_weapon_scale * scale_factor

func equip_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return
	current_index = index
	var data := weapons[current_index]
	sprite.sprite_frames = data.sprite_frames
	current_ammo = data.ammo_max
	is_reloading = false
	_play_animation(&"idle")

func switch_weapon(direction: int) -> void:
	if weapons.size() <= 1:
		return
	equip_weapon(wrapi(current_index + direction, 0, weapons.size()))

func fire() -> void:
	if is_reloading or current_ammo <= 0:
		return

	var data := weapons[current_index]
	current_ammo -= 1
	if sprite.animation != &"shoot" or not sprite.is_playing():
		_play_animation(&"shoot")
	sprite.trigger_recoil()
	if data.is_hitscan:
		_do_hitscan(data)

func reload() -> void:
	if weapons.is_empty() or is_reloading:
		return
	var data := weapons[current_index]
	if current_ammo >= data.ammo_max:
		return
	is_reloading = true
	reload_cooldown = data.reload_time
	_play_animation(&"reload")

func _finish_reload() -> void:
	current_ammo = weapons[current_index].ammo_max
	is_reloading = false
	_play_animation(&"idle")

func _play_animation(animation_name: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)

func _do_hitscan(data: WeaponData) -> void:
	var from := global_position
	var to := from + -global_transform.basis.z * HITSCAN_RANGE
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(data.damage)

func _on_animation_finished() -> void:
	if sprite.animation == &"shoot":
		var data := weapons[current_index]
		if data.is_automatic and Input.is_action_pressed("shoot") and current_ammo > 0:
			_play_animation(&"shoot")
		else:
			_play_animation(&"idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BRACKETLEFT:
			apply_fov(clampf(fov - 5.0, 60.0, 100.0))
		elif event.keycode == KEY_BRACKETRIGHT:
			apply_fov(clampf(fov + 5.0, 60.0, 100.0))
		elif event.keycode == KEY_TAB:
			switch_weapon(1)
		elif event.keycode == KEY_R:
			reload()
