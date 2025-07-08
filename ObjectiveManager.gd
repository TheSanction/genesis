extends Node

var objectives: Dictionary = {}
var active_objectives: Array = []

func _ready():
	pass

func add_objective(objective_id: String):
	if not objectives.has(objective_id):
		var objective_resource = load("res://Objectives/" + objective_id + ".tres")
		if objective_resource:
			objectives[objective_id] = {
				"resource": objective_resource,
				"status": "available"
			}

func start_objective(objective_id: String):
	if objectives.has(objective_id) and objectives[objective_id].status == "available":
		var objective = objectives[objective_id]
		
		# Deduct costs
		for cost in objective.resource.costs:
			GameActions.change_resource(cost.resource, -cost.amount)
			
		# Assess risks
		var is_doomed = false
		var failure_time = 0
		var failure_hook = []
		for risk in objective.resource.risks:
			if randf() < risk.failure_chance:
				is_doomed = true
				failure_time = risk.failure_time_seconds
				failure_hook = risk.on_failure_hook
				break
		
		var active_objective = {
			"id": objective_id,
			"start_time": Time.get_ticks_msec(),
			"is_doomed": is_doomed,
			"failure_time": failure_time,
			"failure_hook": failure_hook
		}
		
		active_objectives.append(active_objective)
		objectives[objective_id].status = "active"

func _process(delta):
	for i in range(active_objectives.size() - 1, -1, -1):
		var active_objective = active_objectives[i]
		var objective_resource = objectives[active_objective.id].resource
		var elapsed_time = (Time.get_ticks_msec() - active_objective.start_time) / 1000.0
		
		if active_objective.is_doomed:
			if elapsed_time >= active_objective.failure_time:
				for hook in active_objective.failure_hook:
					GameActions.callv(hook.action, hook.args)
				objectives[active_objective.id].status = "failed"
				active_objectives.remove_at(i)
		else:
			if elapsed_time >= objective_resource.time_cost.human_seconds:
				for reward in objective_resource.rewards:
					GameActions.callv(reward.action, reward.args)
				if objective_resource.on_complete_hook:
					# Handle completion hook
					pass
				objectives[active_objective.id].status = "done"
				active_objectives.remove_at(i)
