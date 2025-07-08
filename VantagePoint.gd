extends Resource
class_name VantagePoint

@export var tool_id: String
@export var tool_name: String
@export var tool_type: String # "audio" or "video"
@export var description: String
@export var activation_cost: Array[Dictionary]
@export var base_reward: Array[Dictionary]
@export var potential_experiences: Array[String]
