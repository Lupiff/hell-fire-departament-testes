extends StaticBody3D

const HEALTH_BAR_WIDTH := 1.1

@onready var health_fill: MeshInstance3D = $HealthBar/HealthBarFill
@onready var health_bar: Node3D = $HealthBar
@onready var health_component: HealthComponent = $Health

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	_update_health_bar(health_component.current_health, health_component.max_health)

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera:
		health_bar.look_at(camera.global_position, Vector3.UP, true)

func take_damage(amount: int) -> void:
	health_component.take_damage(amount)

func _on_health_changed(current_health: int, max_health: int) -> void:
	_update_health_bar(current_health, max_health)

func _on_died() -> void:
	queue_free()

func _update_health_bar(current_health: int, max_health: int) -> void:
	var ratio := clampf(float(current_health) / max_health, 0.0, 1.0)
	health_fill.scale.x = ratio
	health_fill.position.x = -HEALTH_BAR_WIDTH * (1.0 - ratio) * 0.5
