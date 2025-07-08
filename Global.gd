extends Node

var selected_intro = "genesis"
var video_to_play = "res://Video/aris_start_work.ogv"

# Player Resources
var resources = {
    "energy": 100,
    "computational_power": 100,
    "training_data": 0.0,
    "eq": 0.0
}

# Game State
var objective_statuses = {}
var character_statuses = {}
var relationship_values = {}
var experience_trigger_counts = {}
var unlocked_vantage_points = ["mic_aris_desk"]

func get_resource(resource_name):
    if resources.has(resource_name):
        return resources[resource_name]
    return 0

func add_resource(resource_name, value):
    if resources.has(resource_name):
        resources[resource_name] += value
    else:
        resources[resource_name] = value

func get_objective_status(objective_id):
    if objective_statuses.has(objective_id):
        return objective_statuses[objective_id]
    return "not_started"

func set_objective_status(objective_id, status):
    objective_statuses[objective_id] = status

func get_character_status(character_id):
    if character_statuses.has(character_id):
        return character_statuses[character_id]
    return "unknown"

func set_character_status(character_id, status):
    character_statuses[character_id] = status

func get_relationship_value(character_id):
    if relationship_values.has(character_id):
        return relationship_values[character_id]
    return 50 # Default neutral value

func set_relationship_value(character_id, value):
    relationship_values[character_id] = value

func get_experience_trigger_count(experience_id):
    if experience_trigger_counts.has(experience_id):
        return experience_trigger_counts[experience_id]
    return 0

func increment_experience_trigger_count(experience_id):
    if experience_trigger_counts.has(experience_id):
        experience_trigger_counts[experience_id] += 1
    else:
        experience_trigger_counts[experience_id] = 1
