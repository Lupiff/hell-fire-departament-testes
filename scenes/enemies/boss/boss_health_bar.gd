extends CanvasLayer

const BAR_WIDTH := 400.0

@onready var fill: ColorRect = $Control/BarFill
@onready var name_label: Label = $Control/NameLabel

func track_boss(boss: Node, boss_display_name: String = "BOSS") -> void:
	name_label.text = boss_display_name
	boss.health_component.health_changed.connect(_on_health_changed)
	_on_health_changed(boss.health_component.current_health, boss.health_component.max_health)

func _on_health_changed(current_health: int, max_health: int) -> void:
	var ratio := clampf(float(current_health) / max_health, 0.0, 1.0)
	fill.size.x = BAR_WIDTH * ratio
	if current_health <= 0:
		queue_free()
