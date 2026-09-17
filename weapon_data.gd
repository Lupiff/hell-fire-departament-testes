extends Resource
class_name WeaponData

@export var name: String
@export var sprite_frames: SpriteFrames
@export var damage: int
@export var fire_rate: float  # tiros por segundo
@export var ammo_max: int
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
@export var is_hitscan: bool = true
@export var is_automatic: bool = false
