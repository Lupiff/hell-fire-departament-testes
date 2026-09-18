extends StaticBody3D

const HEALTH_BAR_WIDTH := 1.1

@export var max_health := 100
var health := 100

@onready var health_fill: MeshInstance3D = $HealthBarFill

func _ready() -> void:
	health = max_health
	_update_health_bar()

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	_update_health_bar()
	if health == 0:
		queue_free()

func _update_health_bar() -> void:
	var ratio := float(health) / max_health
	health_fill.scale.x = ratio
	health_fill.position.x = -HEALTH_BAR_WIDTH * (1.0 - ratio) * 0.5
