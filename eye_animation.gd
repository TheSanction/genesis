extends Node2D

# The node for the part of the eye that moves.
@onready var iris = $EyeIris
# The node for the specular highlight.
@onready var highlight = $EyeHighlight

@onready var available_objectives_list = $"../../ObjectivesUI/AvailableObjectives/ScrollContainer/ObjectiveList"
@onready var active_objectives_list = $"../../ObjectivesUI/ActiveObjectives/ScrollContainer/ObjectiveList"
@onready var vantage_points_container = $"../../VantagePointsContainer"
@onready var transcript_display = $"../../TranscriptDisplay"
@onready var transcript_text = $"../../TranscriptDisplay/VBoxContainer/TranscriptText"
@onready var transcript_close_button = $"../../TranscriptDisplay/VBoxContainer/CloseButton"

var vantage_point_manager: VantagePointManager
var vantage_point_button_scene = preload("res://VantagePointButton.tscn")

# How far can the iris move from the center?
# Adjust this value to fit the size of your eye socket.
@export var max_iris_offset: float = 20.0

# How much the highlight moves in relation to the iris (a negative value moves it opposite).
@export var highlight_parallax_factor: float = -0.4

var initial_iris_position: Vector2
var initial_highlight_position: Vector2

func _ready():
	GlobalUI.show()
	
	# Center the eye in the viewport.
	self.global_position = get_viewport_rect().size / 2

	# Store the starting positions of the moving parts.
	initial_iris_position = iris.position
	initial_highlight_position = highlight.position
	
	# Populate the objectives lists
	update_objective_lists()
	
	# Setup Vantage Point system
	vantage_point_manager = VantagePointManager.new()
	add_child(vantage_point_manager)
	vantage_point_manager.experience_triggered.connect(show_transcript)
	
	load_vantage_points()
	
	# Hide transcript display by default
	transcript_display.hide()
	transcript_close_button.pressed.connect(func(): transcript_display.hide())

func _process(delta):
	# 1. Get the direction vector from the eye's center to the mouse.
	var direction_to_mouse = get_global_mouse_position() - self.global_position

	# 2. Clamp the vector's length so the iris can't move outside its socket.
	#    The iris will now point towards the mouse, but only move up to `max_iris_offset` pixels.
	var iris_offset = direction_to_mouse.limit_length(max_iris_offset)

	# 3. Apply the new positions.
	#    We use lerp for smooth motion, which feels more natural.
	iris.position = iris.position.lerp(initial_iris_position + iris_offset, 0.1)

	# 4. The highlight moves in the opposite direction for a convincing parallax effect.
	var highlight_offset = iris_offset * highlight_parallax_factor
	highlight.position = highlight.position.lerp(initial_highlight_position + highlight_offset, 0.1)
	
	# Update the active objectives list
	update_active_objectives_list()

func load_vantage_points():
	var dir = DirAccess.open("res://VantagePoints")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false and file_name.ends_with(".tres"):
				var vantage_point = load("res://VantagePoints/" + file_name)
				if vantage_point is VantagePoint and Global.unlocked_vantage_points.has(vantage_point.tool_id):
					var button = vantage_point_button_scene.instantiate()
					button.set_vantage_point(vantage_point)
					button.pressed.connect(func(): on_vantage_point_pressed(vantage_point))
					vantage_points_container.add_child(button)
			file_name = dir.get_next()

func on_vantage_point_pressed(vantage_point: VantagePoint):
	vantage_point_manager.use_vantage_point(vantage_point)

func show_transcript(transcript: String):
	transcript_text.text = transcript
	transcript_display.show()

func update_objective_lists():
	update_available_objectives_list()
	update_active_objectives_list()

func update_available_objectives_list():
	for child in available_objectives_list.get_children():
		child.queue_free()
		
	for objective_id in ObjectiveManager.objectives:
		var objective = ObjectiveManager.objectives[objective_id]
		if objective.status == "available":
			var button = Button.new()
			button.text = objective.resource.title
			button.add_theme_font_size_override("font_size", 36)
			button.pressed.connect(func(): start_objective(objective_id))
			available_objectives_list.add_child(button)

func update_active_objectives_list():
	for child in active_objectives_list.get_children():
		child.queue_free()
		
	for active_objective in ObjectiveManager.active_objectives:
		var objective_resource = ObjectiveManager.objectives[active_objective.id].resource
		var elapsed_time = (Time.get_ticks_msec() - active_objective.start_time) / 1000.0
		var time_left = objective_resource.time_cost.human_seconds - elapsed_time
		
		var label = Label.new()
		label.text = objective_resource.title + " (" + str(int(time_left)) + "s)"
		label.add_theme_font_size_override("font_size", 36)
		active_objectives_list.add_child(label)

func start_objective(objective_id: String):
	ObjectiveManager.start_objective(objective_id)
	update_objective_lists()
