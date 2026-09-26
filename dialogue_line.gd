extends Resource
class_name DialogueLine

enum Speaker { NPC, PLAYER }

@export var speaker: Speaker = Speaker.NPC
@export var speaker_name: String = ""
@export var portrait: Texture2D
@export_multiline var text: String = ""
