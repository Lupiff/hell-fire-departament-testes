extends Node
class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal died

@export_range(1, 10000, 1) var max_health := 100
var current_health := 0

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func set_max_health(value: int) -> void:
	max_health = max(value, 1)
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	if current_health <= 0 or amount <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	if current_health <= 0 or amount <= 0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
