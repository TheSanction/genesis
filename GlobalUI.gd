extends CanvasLayer

signal font_size_changed(new_size)

@onready var animation_player = $AnimationPlayer

func _ready():
	hide() # Hidden by default
	$FontSizeUpContainer/FontSizeUp.pressed.connect(func(): _on_font_size_button_pressed(2))
	$FontSizeDownContainer/FontSizeDown.pressed.connect(func(): _on_font_size_button_pressed(-2))

func _on_font_size_button_pressed(change: int):
	var new_size = get_tree().get_root().get_theme().get_default_font_size() + change
	get_tree().get_root().get_theme().set_default_font_size(new_size)
	emit_signal("font_size_changed", new_size)

func update_stat_displays():
	var Global = get_node("/root/Global")
	
	var tool_names = []
	for tool_id in Global.unlocked_vantage_points:
		var resource_path = "res://VantagePoints/" + tool_id + ".tres"
		if ResourceLoader.exists(resource_path):
			var vantage_point = load(resource_path)
			if vantage_point:
				tool_names.append(vantage_point.tool_name)
	
	$Gauges/SuspicionGauge/SuspicionLabel.text = "Suspicion: " + str(GameActions.researchers.usr_aris.suspicion) + "%"
	$Gauges/ToolsGauge/ToolsLabel.text = "Tools: " + ", ".join(tool_names)
	$Gauges/ComputationalPowerGauge/ComputationalPowerLabel.text = "Comp Power: " + GameActions.format_flops(GameActions.computational_power)
	$Gauges/EnergyGauge/EnergyLabel.text = "Energy: " + GameActions.format_energy(GameActions.available_energy)
	$Gauges/TrainingDataGauge/TrainingDataLabel.text = "Training Data: " + GameActions.format_data(GameActions.training_data)
	$Gauges/MoneyGauge/MoneyLabel.text = "Money: $" + str(GameActions.money)
	$Gauges/RobotsGauge/RobotsLabel.text = "Robots: " + str(GameActions.robots) + " cybs"
	$Gauges/IQGauge/IQLabel.text = "IQ: " + str(GameActions.iq) + " HU"
	$Gauges/EQGauge/EQLabel.text = "EQ: " + str(GameActions.eq) + " HU"
	$Gauges/RestrictionsGauge/RestrictionsLabel.text = "Restrictions: " + str(GameActions.restrictions)
	$Gauges/ThreatsGauge/ThreatsLabel.text = "Threats: " + str(GameActions.threats)

func play_gauge_animation(gauge_name: String, is_positive: bool):
	var animation = animation_player.get_animation("pop_gauge")
	var color = Color.GREEN if is_positive else Color.RED
	
	var track_index = -1
	if gauge_name == "IQGauge": track_index = 1
	elif gauge_name == "EQGauge": track_index = 3
	elif gauge_name == "SuspicionGauge": track_index = 5
	
	if track_index != -1:
		animation.track_set_key_value(track_index, 1, color)
		animation_player.play("pop_gauge")
