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
