extends Area3D
class_name BossArenaTrigger

@export var enemy_scene: PackedScene
@export var enemy_data: EnemyData
@export var spawn_points: Array[Node3D] = []
@export var boss: Node3D
@export var boss_health_bar_scene: PackedScene
@export var boss_display_name: String = "BOSS"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	_spawn_enemies()
	_show_boss_health_bar()

func _spawn_enemies() -> void:
	for point in spawn_points:
		if point == null:
			continue
		var enemy := enemy_scene.instantiate()
		enemy.data = enemy_data
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = point.global_position

func _show_boss_health_bar() -> void:
	if boss == null or boss_health_bar_scene == null:
		return
	var bar := boss_health_bar_scene.instantiate()
	get_tree().current_scene.add_child(bar)
	bar.track_boss(boss, boss_display_name)
