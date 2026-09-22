extends Camera3D

const BASE_FOV := 75.0
const HITSCAN_RANGE := 1000.0
const TRACER_SCRIPT := preload("res://scripts/weapons/tracer.gd")
const HEALTH_BAR_WIDTH := 220.0

@export var weapons: Array[WeaponData] = []

var base_weapon_scale: Vector3
var current_index := 0
var current_ammo := 0
var fire_cooldown := 0.0
var reload_cooldown := 0.0
var is_reloading := false

var magazine_ammo: Array[int] = []
var reserve_by_type: Dictionary = {}
var unlocked: Array[bool] = []

@onready var sprite: AnimatedSprite3D = $WeaponSprite3D
@onready var ammo_label: Label = $AmmoHud/AmmoLabel
@onready var fire_audio: AudioStreamPlayer = $FireAudio
@onready var muzzle: Marker3D = $Muzzle
@onready var muzzle_flash_light: OmniLight3D = $Muzzle/MuzzleFlashLight
@onready var player_health: HealthComponent = $"../../Health"
@onready var health_bar_fill: ColorRect = $AmmoHud/HealthBarFill
@onready var health_label: Label = $AmmoHud/HealthLabel

var muzzle_flash_tween: Tween

func _ready() -> void:
	base_weapon_scale = sprite.scale
	fov = BASE_FOV
	sprite.animation_finished.connect(_on_animation_finished)
	player_health.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player_health.current_health, player_health.max_health)

	magazine_ammo.resize(weapons.size())
	unlocked.resize(weapons.size())
	for i in weapons.size():
		magazine_ammo[i] = weapons[i].ammo_max
		unlocked[i] = weapons[i].starts_unlocked
		if not weapons[i].is_melee and not reserve_by_type.has(weapons[i].ammo_type):
			reserve_by_type[weapons[i].ammo_type] = 0

	var start_index := 0
	for i in weapons.size():
		if unlocked[i]:
			start_index = i
			break

	if not weapons.is_empty():
		equip_weapon(start_index)

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
	if not unlocked[index]:
		return
	current_index = index
	var data := weapons[current_index]
	sprite.sprite_frames = data.sprite_frames
	current_ammo = magazine_ammo[current_index]
	is_reloading = false
	fire_cooldown = 0.0
	_update_ammo_hud()
	_play_animation(&"idle")

func equip_weapon_by_slot(slot_number: int) -> void:
	var index := slot_number - 1
	if index < 0 or index >= weapons.size():
		return
	if not unlocked[index]:
		return
	equip_weapon(index)

func unlock_weapon(weapon_data: WeaponData) -> void:
	var idx := weapons.find(weapon_data)
	if idx == -1:
		return
	if unlocked[idx]:
		return
	unlocked[idx] = true
	equip_weapon(idx)

func switch_weapon(direction: int) -> void:
	if weapons.size() <= 1:
		return
	var idx := current_index
	for i in weapons.size():
		idx = wrapi(idx + direction, 0, weapons.size())
		if unlocked[idx]:
			equip_weapon(idx)
			return

func fire() -> void:
	var data := weapons[current_index]

	if not data.is_melee:
		if is_reloading or current_ammo <= 0:
			return
		current_ammo -= 1
		magazine_ammo[current_index] = current_ammo
		_update_ammo_hud()

	_play_fire_sound(data)

	if not data.is_melee:
		_play_muzzle_flash()

	if sprite.animation != &"shoot" or not sprite.is_playing():
		_play_animation(&"shoot")
	sprite.trigger_recoil()

	if data.is_melee:
		_do_melee(data)
	elif data.is_hitscan:
		var hit_position := _do_hitscan(data)
		_spawn_tracer(muzzle.global_position, hit_position)

func _do_melee(data: WeaponData) -> void:
	var from := global_position
	var to := from + -global_transform.basis.z * data.melee_range
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent().get_parent()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(data.damage)

func reload() -> void:
	if weapons.is_empty() or is_reloading:
		return
	var data := weapons[current_index]
	if data.is_melee:
		return
	if current_ammo >= data.ammo_max:
		return
	var available: int = reserve_by_type.get(data.ammo_type, 0)
	if available <= 0:
		return
	is_reloading = true
	reload_cooldown = data.reload_time
	_play_animation(&"reload")

func _finish_reload() -> void:
	var data := weapons[current_index]
	var needed := data.ammo_max - current_ammo
	var available: int = reserve_by_type.get(data.ammo_type, 0)
	var transfer := mini(needed, available)

	current_ammo += transfer
	magazine_ammo[current_index] = current_ammo
	reserve_by_type[data.ammo_type] = available - transfer

	is_reloading = false
	_update_ammo_hud()
	_play_animation(&"idle")

func add_ammo(amount: int, ammo_type: String) -> void:
	if not reserve_by_type.has(ammo_type):
		return
	var cap := reserve_ammo_max_for_type(ammo_type)
	var current_reserve: int = reserve_by_type[ammo_type]
	reserve_by_type[ammo_type] = mini(current_reserve + amount, cap)
	_update_ammo_hud()

func reserve_ammo_max_for_type(ammo_type: String) -> int:
	for w in weapons:
		if w.ammo_type == ammo_type:
			return w.reserve_ammo_max
	return 999999

func _update_ammo_hud() -> void:
	if weapons.is_empty():
		ammo_label.text = ""
		return
	var data := weapons[current_index]
	if data.is_melee:
		ammo_label.text = ""
		return
	var reserve: int = reserve_by_type.get(data.ammo_type, 0)
	ammo_label.text = "%d / %d" % [current_ammo, reserve]

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	var ratio := clampf(float(current_health) / max_health, 0.0, 1.0)
	health_bar_fill.offset_right = 24.0 + HEALTH_BAR_WIDTH * ratio
	health_label.text = "VIDA %d / %d" % [current_health, max_health]

func _play_fire_sound(data: WeaponData) -> void:
	if data.fire_sound:
		fire_audio.stream = data.fire_sound
		fire_audio.play()

func _play_muzzle_flash() -> void:
	if muzzle_flash_tween:
		muzzle_flash_tween.kill()
	muzzle_flash_light.light_energy = 4.0
	muzzle_flash_tween = create_tween()
	muzzle_flash_tween.tween_property(muzzle_flash_light, "light_energy", 0.0, 0.045)

func _play_animation(animation_name: StringName) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)

func _do_hitscan(data: WeaponData) -> Vector3:
	var from := global_position
	var to := from + -global_transform.basis.z * HITSCAN_RANGE
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent().get_parent()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result:
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(data.damage)
		return result.position
	return to

func _spawn_tracer(from: Vector3, to: Vector3) -> void:
	var tracer := TRACER_SCRIPT.new()
	get_tree().current_scene.add_child(tracer)
	tracer.show_between(from, to)

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
		elif event.keycode == KEY_R:
			reload()
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			equip_weapon_by_slot(event.keycode - KEY_1 + 1)
