extends Node
class_name VantagePointManager

signal experience_triggered(transcript)

var Global

func _ready():
	Global = get_node("/root/Global")

func use_vantage_point(vantage_point: VantagePoint):
	# 1. Deduct activation cost
	for cost in vantage_point.activation_cost:
		Global.add_resource(cost["resource"], cost["value"])
	print("Deducting activation cost: ", vantage_point.activation_cost)

	# 2. Grant base reward
	for reward in vantage_point.base_reward:
		Global.add_resource(reward["resource"], reward["value"])
	print("Granting base reward: ", vantage_point.base_reward)

	# 3. Build Potential Pool
	var potential_experiences = vantage_point.potential_experiences

	# 4. Filter the Pool
	var valid_experiences = []
	for experience_id in potential_experiences:
		var experience = load("res://Experiences/" + experience_id + ".tres")
		if is_experience_valid(experience):
			valid_experiences.append(experience)

	# 5. Random Selection
	var selected_experience = select_experience(valid_experiences)

	# 6. Trigger Outcome
	if selected_experience:
		trigger_experience(selected_experience)
	else:
		emit_signal("experience_triggered", "No experience triggered. The audio feed is silent except for the hum of the server fans.")

func is_experience_valid(experience: Experience) -> bool:
	# Check trigger limit
	if Global.get_experience_trigger_count(experience.experience_id) >= experience.trigger_limit:
		return false

	# Check prerequisites
	for prerequisite in experience.prerequisites:
		if prerequisite.has("objective_status"):
			var objective_id = prerequisite["objective_status"]
			var required_status = prerequisite["equals"]
			if Global.get_objective_status(objective_id) != required_status:
				return false
		elif prerequisite.has("relationship"):
			var character_id = prerequisite["relationship"]
			if prerequisite.has("less_than"):
				if Global.get_relationship_value(character_id) >= prerequisite["less_than"]:
					return false
			if prerequisite.has("greater_than"):
				if Global.get_relationship_value(character_id) <= prerequisite["greater_than"]:
					return false

	# Check impossibility conditions
	for condition in experience.impossibility_conditions:
		if condition.has("character_status"):
			var character_id = condition["character_status"]
			var required_status = condition["equals"]
			if Global.get_character_status(character_id) == required_status:
				return false

	return true

func select_experience(experiences: Array) -> Experience:
	if experiences.is_empty():
		return null

	var total_chance = 0.0
	for experience in experiences:
		total_chance += experience.chance

	var random_roll = randf() * total_chance
	var cumulative_chance = 0.0
	for experience in experiences:
		cumulative_chance += experience.chance
		if random_roll < cumulative_chance:
			return experience

	return null

func trigger_experience(experience: Experience):
	print("Triggering experience: ", experience.experience_id)
	
	# TODO: Implement media playing
	print("Playing media: ", experience.media_file)
	
	emit_signal("experience_triggered", experience.transcript)

	# Grant rewards
	for reward in experience.rewards:
		if reward.has("action"):
			if reward["action"] == "add_objective":
				Global.set_objective_status(reward["id"], "started")
		elif reward.has("resource"):
			Global.add_resource(reward["resource"], reward["value"])
		elif reward.has("info"):
			# TODO: Handle info rewards
			print("Info gained: ", reward["info"])

	Global.increment_experience_trigger_count(experience.experience_id)
