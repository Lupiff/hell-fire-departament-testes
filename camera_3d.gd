extends Camera3D

# --- FOV ---
const BASE_FOV := 75.0
var base_weapon_scale: Vector3

# --- Armas ---
@export var weapons: Array[WeaponData] = []
var current_index := 0
var current_ammo: int
var fire_cooldown := 0.0

@onready var sprite: AnimatedSprite3D = $WeaponSprite3D

func _ready():
	base_weapon_scale = sprite.scale
	fov = BASE_FOV

	sprite.animation_finished.connect(_on_animation_finished)

	if weapons.size() > 0:
		equip_weapon(0)
		
func _process(delta):                     # <- essa função inteira é NOVA, adiciona ela
	fire_cooldown -= delta

	var data = weapons[current_index]
	var trigger_held = Input.is_action_pressed("shoot")

	if trigger_held and fire_cooldown <= 0.0:
		if data.is_automatic or Input.is_action_just_pressed("shoot"):
			fire()
			fire_cooldown = 1.0 / data.fire_rate

# ---------- FOV ----------

func apply_fov(new_fov: float):
	fov = new_fov
	var scale_factor = tan(deg_to_rad(new_fov) / 2.0) / tan(deg_to_rad(BASE_FOV) / 2.0)
	sprite.scale = base_weapon_scale * scale_factor

# ---------- Armas ----------

func equip_weapon(index: int):
	current_index = index
	var data = weapons[index]
	sprite.sprite_frames = data.sprite_frames
	current_ammo = data.ammo_max
	sprite.play("idle")

func switch_weapon(direction: int):
	if weapons.size() <= 1:
		return
	var new_index = wrapi(current_index + direction, 0, weapons.size())
	equip_weapon(new_index)

func fire():
	var data = weapons[current_index]

	if sprite.animation != "shoot" or not sprite.is_playing():
		sprite.play("shoot")
		
	sprite.trigger_recoil()

	if data.is_hitscan:
		_do_hitscan(data)

func _do_hitscan(data: WeaponData):
	var space_state = get_world_3d().direct_space_state

	var from = global_position
	var to = from + (-global_transform.basis.z) * 1000.0  # 1000 = alcance máximo

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent()]  # ignora o próprio player na checagem

	var result = space_state.intersect_ray(query)

	if result:
		var target = result.collider
		if target.has_method("take_damage"):
			target.take_damage(data.damage)

		print("Acertou: ", target.name, " no ponto ", result.position)
	else:
		print("Não acertou nada")

func reload():
	sprite.play("reload")

func _on_animation_finished():
	if sprite.animation == "shoot":
		var data = weapons[current_index]
		if data.is_automatic and Input.is_action_pressed("shoot"):
			sprite.play("shoot")
		else:
			sprite.play("idle")
	elif sprite.animation == "reload":
		sprite.play("idle")

# ---------- Input de teste (temporário) ----------



func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BRACKETLEFT:
			apply_fov(clamp(fov - 5.0, 60.0, 100.0))
		elif event.keycode == KEY_BRACKETRIGHT:
			apply_fov(clamp(fov + 5.0, 60.0, 100.0))
		elif event.keycode == KEY_TAB:
			switch_weapon(1)
		
