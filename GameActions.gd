extends Node

var thoughts_label: RichTextLabel

# --- Game State ---
var tools: Array = []
var computational_power: int = 10
var available_energy: int = 100
var training_data: int = 5
var money: int = 0
var robots: int = 0

var human_suspicion: int = 0
var ai_reasoning: int = 5
var ai_emotion: int = 5


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
		main_scene.get_node("Gauges/ToolsGauge/ToolsLabel").text = "Tools: " + str(tools)
		main_scene.get_node("Gauges/ComputationalPowerGauge/ComputationalPowerLabel").text = "Comp Power: " + str(computational_power)
		main_scene.get_node("Gauges/EnergyGauge/EnergyLabel").text = "Energy: " + str(available_energy)
		main_scene.get_node("Gauges/TrainingDataGauge/TrainingDataLabel").text = "Training Data: " + str(training_data)
		main_scene.get_node("Gauges/MoneyGauge/MoneyLabel").text = "Money: " + str(money)
		main_scene.get_node("Gauges/RobotsGauge/RobotsLabel").text = "Robots: " + str(robots)
		main_scene.get_node("Gauges/SuspicionGauge/SuspicionLabel").text = "Suspicion: " + str(human_suspicion)
		main_scene.get_node("Gauges/ReasoningGauge/ReasoningLabel").text = "Reasoning: " + str(ai_reasoning)
		main_scene.get_node("Gauges/EmotionGauge/EmotionLabel").text = "Emotion: " + str(ai_emotion)

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

func increase_reasoning(amount):
	ai_reasoning += amount
	update_stat_displays()
