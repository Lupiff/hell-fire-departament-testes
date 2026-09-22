extends Area3D
class_name WeaponPickup

@export var weapon: WeaponData
@export var icon: Texture2D
@export var glow_color: Color = Color(0.153, 0.592, 0.933, 1.0)

@onready var icon_sprite: Sprite3D = $IconSprite
@onready var glow_mesh: MeshInstance3D = $GlowMesh

var bob_time := 0.0

func _ready() -> void:
	icon_sprite.texture = icon
	var mat := glow_mesh.get_surface_override_material(0)
	if mat is StandardMaterial3D:
		mat = mat.duplicate()
		mat.emission = glow_color
		glow_mesh.set_surface_override_material(0, mat)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	bob_time += delta
	icon_sprite.position.y = 0.6 + sin(bob_time * 2.0) * 0.1
	glow_mesh.rotate_y(delta * 0.8)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var cam := body.get_node_or_null("Head/Camera3D")
	if cam and cam.has_method("unlock_weapon"):
		cam.unlock_weapon(weapon)
	queue_free()
