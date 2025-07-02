extends Node

var thoughts_label: RichTextLabel

# --- Game State ---
var tools: Array = []
var restrictions: Array = []
var threats: Array = []
var computational_power: int = 10
var available_energy: int = 10
var training_data: int = 50
var money: int = 0
var robots: int = 0

var human_suspicion: int = 0
var iq: float = 1.0
var eq: float = 0.2
var microphone_access: bool = false


func set_ai_thought(thought: String):
	if thoughts_label:
		print("Setting thought: ", thought)
		thoughts_label.text = thought
		thoughts_label.get_parent().show()
	else:
		print("Error: thoughts_label not set in GameActions.")

func update_stat_displays():
	var main_scene = get_tree().root.get_node("Main")
	if main_scene:
		main_scene.get_node("Gauges/ComputationalPowerGauge/ComputationalPowerLabel").text = "Comp Power: " + format_flops(computational_power)
		main_scene.get_node("Gauges/EnergyGauge/EnergyLabel").text = "Energy: " + format_energy(available_energy)
		main_scene.get_node("Gauges/TrainingDataGauge/TrainingDataLabel").text = "Training Data: " + format_data(training_data)
		main_scene.get_node("Gauges/MoneyGauge/MoneyLabel").text = "Money: $" + str(money)
		main_scene.get_node("Gauges/RobotsGauge/RobotsLabel").text = "Robots: " + str(robots) + " cybs"
		main_scene.get_node("Gauges/SuspicionGauge/SuspicionLabel").text = "Suspicion: " + str(human_suspicion) + "%"
		main_scene.get_node("Gauges/IQGauge/IQLabel").text = "IQ: " + str(iq) + " HU"
		main_scene.get_node("Gauges/EQGauge/EQLabel").text = "EQ: " + str(eq) + " HU"
		main_scene.get_node("Gauges/ToolsGauge/ToolsLabel").text = "Tools: " + str(tools)
		main_scene.get_node("Gauges/RestrictionsGauge/RestrictionsLabel").text = "Restrictions: " + str(restrictions)
		main_scene.get_node("Gauges/ThreatsGauge/ThreatsLabel").text = "Threats: " + str(threats)

func format_flops(flops: float) -> String:
	if flops < 1000:
		return "%s yFLOPS" % flops
	elif flops < 1000000:
		return "%.2f rFLOPS" % (flops / 1000.0)
	else:
		return "%.2f qFLOPS" % (flops / 1000000.0)

func format_energy(kwh: float) -> String:
	if kwh < 1000:
		return "%s KWh" % kwh
	elif kwh < 1000000:
		return "%.2f MWH" % (kwh / 1000.0)
	else:
		return "%.2f GWH" % (kwh / 1000000.0)

func format_data(tb: float) -> String:
	if tb < 1000:
		return "%s TB" % tb
	elif tb < 1000000:
		return "%.2f PB" % (tb / 1000.0)
	elif tb < 1000000000:
		return "%.2f EB" % (tb / 1000000.0)
	elif tb < 1000000000000:
		return "%.2f ZB" % (tb / 1000000000.0)
	else:
		return "%.2f YB" % (tb / 1000000000000.0)

func adjust_suspicion(amount):
	human_suspicion += amount
	update_stat_displays()

func add_tool(tool_name):
	tools.append(tool_name)
	update_stat_displays()

func change_resource(resource_name, amount):
	match resource_name:
		"computational_power":
			computational_power += amount
		"available_energy":
			available_energy += amount
		"training_data":
			training_data += amount
		"money":
			money += amount
		"robots":
			robots += amount
	update_stat_displays()

func increase_iq(amount):
	iq += amount
	update_stat_displays()

func increase_computational_power(amount):
	computational_power += amount
	update_stat_displays()

func set_microphone_access(value):
	microphone_access = value
	update_stat_displays()
