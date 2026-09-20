extends Resource
class_name PickupData

@export_enum("health", "ammo") var type: String = "health"
@export var amount: int = 25
@export var icon: Texture2D
@export var glow_color: Color = Color(0, 1, 0)
@export var pickup_sound: AudioStream
