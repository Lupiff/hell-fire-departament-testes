extends Area3D
class_name Pickup

@export var data: PickupData

@onready var icon_sprite: Sprite3D = $IconSprite
@onready var glow_mesh: MeshInstance3D = $GlowMesh

var bob_time := 0.0

func _ready() -> void:
	icon_sprite.texture = data.icon

	var mat := glow_mesh.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		mat.emission = data.glow_color

	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	bob_time += delta
	icon_sprite.position.y = 0.6 + sin(bob_time * 2.0) * 0.1
	glow_mesh.rotate_y(delta * 0.8)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	match data.type:
		"health":
			var health_comp: HealthComponent = body.get_node_or_null("Health")
			if health_comp == null:
				return
			if health_comp.current_health >= health_comp.max_health:
				return
			if body.has_method("heal"):
				body.heal(data.amount)
		"ammo":
			var cam := body.get_node_or_null("Head/Camera3D")
			if cam and cam.has_method("add_ammo"):
				cam.add_ammo(data.amount, data.ammo_type)
		_:
			return

	queue_free()
