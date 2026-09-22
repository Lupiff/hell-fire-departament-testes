extends Resource
class_name EnemyData

@export var name: String
@export var max_health: int = 50
@export var move_speed: float = 3.0
@export var damage: int = 10

@export_enum("melee", "ranged") var attack_type: String = "melee"
@export var attack_range: float = 2.0        # melee: distância de contato; ranged: alcance de tiro
@export var attack_cooldown: float = 1.5
@export var detection_range: float = 15.0    # distância pra começar a perseguir

@export var sprite_variants: Array[SpriteFrames] = []  # as 2-3 variantes visuais desse tipo

# drops

@export var drop_chance: float = 0.3   # 30% de chance
@export var possible_drops: Array[PickupData] = []
