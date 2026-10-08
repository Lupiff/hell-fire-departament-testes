extends Resource
class_name WeaponData

@export var name: String
@export var sprite_frames: SpriteFrames
@export var damage: int
@export var fire_rate: float  # tiros por segundo (ou "golpes por segundo" no melee)
@export var ammo_max: int
@export_range(0.0, 10.0, 0.1) var reload_time: float = 1.5
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
@export var is_hitscan: bool = true
@export var is_automatic: bool = false
@export var is_melee: bool = false          # <- novo
@export var melee_range: float = 2.5         # <- novo, alcance do golpe
@export var reserve_ammo_max: int = 90
@export_enum("Pistol", "MP-40", "Doze") var ammo_type: String = "Pistol" # tem que ser IDENTICO ao q ta no pickupData
@export var melee_damage_frame: int = 2   # índice 0-based; "3º frame" = índice 2
@export var starts_unlocked: bool = false

#shotgun coisas

@export var pellet_count: int = 1                              # quantos projéteis por tiro
@export_range(0.0, 15.0, 0.1) var spread_angle: float = 0.0    # espalhamento em graus
@export var pump_after_shot: bool = false                      # toca a animação "pump" depois de cada tiro
@export var pump_sound: AudioStream
