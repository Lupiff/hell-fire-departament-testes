extends Camera3D

const BASE_FOV := 75.0

var base_weapon_scale: Vector3

func _ready():
	base_weapon_scale = $WeaponSprite3D.scale
	fov = BASE_FOV

func apply_fov(new_fov: float):
	fov = new_fov

	var scale_factor = tan(deg_to_rad(new_fov) / 2.0) / tan(deg_to_rad(BASE_FOV) / 2.0)
	$WeaponSprite3D.scale = base_weapon_scale * scale_factor

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_BRACKETLEFT:
			apply_fov(clamp(fov - 5.0, 60.0, 100.0))
		elif event.keycode == KEY_BRACKETRIGHT:
			apply_fov(clamp(fov + 5.0, 60.0, 100.0))
