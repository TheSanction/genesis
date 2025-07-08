extends Resource
class_name Experience

@export var experience_id: String
@export var media_file: String
@export var transcript: String
@export var prerequisites: Array[Dictionary]
@export var impossibility_conditions: Array[Dictionary]
@export var trigger_limit: int = 1
@export var chance: float = 1.0
@export var rewards: Array[Dictionary]
