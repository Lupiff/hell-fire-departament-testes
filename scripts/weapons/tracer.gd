extends MeshInstance3D

const LIFETIME := 0.06

func show_between(from: Vector3, to: Vector3) -> void:
	var distance := from.distance_to(to)
	if distance <= 0.01:
		queue_free()
		return

	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.006
	cylinder.bottom_radius = 0.006
	cylinder.height = distance

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.78, 0.18, 1.0)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.42, 0.04, 1.0)
	cylinder.material = material
	mesh = cylinder
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	global_position = from.lerp(to, 0.5)
	look_at(to, Vector3.UP)
	rotate_object_local(Vector3.RIGHT, PI * 0.5)

	await get_tree().create_timer(LIFETIME).timeout
	queue_free()
