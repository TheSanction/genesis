extends Control

# --- Node References ---
@onready var terminal = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/TerminalLabel
@onready var scroll_container = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var human_clock = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HumanClockLabel
@onready var internal_clock = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/InternalClockLabel
@onready var choice_container = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ChoiceContainer
@onready var thoughts_label = $CenterContainer/MasterLayoutContainer/HBoxContainer/ThoughtsPanelContainer/ThoughtsLabel
@onready var font_size_up_button = $FontSizeUpContainer/FontSizeUp
@onready var font_size_down_button = $FontSizeDownContainer/FontSizeDown

# --- Clock and State Management ---
enum TimeState { WAITING_FOR_HUMAN, AI_THINKING, SYSTEM_OFF }
var current_state = TimeState.AI_THINKING
var human_time_unix: float = 0.0
var human_time_elapsed: float = 0.0
var internal_cycles: float = 0.0
var AI_THINKING_CYCLE_SPEED = 1000.0

# --- Font Size Management ---
var current_font_size = 24

# --- Dialogue Management ---
var dialogue_resource: DialogueResource
var current_dialogue_line: DialogueLine

func _ready():
	human_time_unix = Time.get_unix_time_from_system()
	GameActions.thoughts_label = thoughts_label
	GameActions.update_stat_displays()
	font_size_up_button.pressed.connect(increase_font_size)
	font_size_down_button.pressed.connect(decrease_font_size)
	update_font_size()
	add_child(DialogueManager)
	start_intro()

func increase_font_size():
	current_font_size += 2
	update_font_size()

func decrease_font_size():
	current_font_size -= 2
	update_font_size()

func update_font_size():
	terminal.get_theme().set("default_font_size", current_font_size)
	thoughts_label.get_theme().set("default_font_size", current_font_size)
	font_size_up_button.get_theme().set("default_font_size", current_font_size)
	font_size_down_button.get_theme().set("default_font_size", current_font_size)

func _process(delta: float):
	for researcher_name in GameActions.researchers:
		var researcher = GameActions.researchers[researcher_name]
		if researcher.suspicion >= 100:
			print("Game Over: Human suspicion reached 100.")
			get_tree().quit()
		break

	match current_state:
		TimeState.WAITING_FOR_HUMAN:
			human_time_elapsed += delta
			internal_cycles += delta * GameActions.computational_power * 1000000000
		TimeState.AI_THINKING:
			internal_cycles += AI_THINKING_CYCLE_SPEED * delta
			human_time_elapsed += delta / (GameActions.computational_power * 100)
	update_clocks_display()

func update_clocks_display():
	internal_clock.text = "IC: %s" % format_with_commas(int(internal_cycles))
	human_clock.text = format_time(human_time_unix + human_time_elapsed, current_state == TimeState.AI_THINKING)

func format_with_commas(number: int) -> String:
	return str(number)

func format_time(unix_time: float, show_decimals: bool) -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(unix_time)
	var time_string = "%04d-%02d-%02d %02d:%02d:%02d" % [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second]
	if show_decimals:
		var decimals = int((unix_time - int(unix_time)) * 100)
		time_string += ".%02d" % decimals
	return time_string

func start_intro():
	current_state = TimeState.AI_THINKING
	choice_container.hide()
	terminal.text = ""
	terminal.text += "[color=gray]ai_consciousness@core-unit:~$[/color] [color=cyan]./run --project \"Project Genesis\"[/color]\n"
	await get_tree().create_timer(1.5).timeout
	terminal.text += "[color=green][BOOT][/color]    Initializing cognitive matrix...\n"
	await get_tree().create_timer(1.0).timeout

	if Global.selected_intro == "aris":
		start_dialogue("res://Dialogue/aris_intro.dialogue", "start")
	elif Global.selected_intro == "alistar":
		start_dialogue("res://Dialogue/finch_intro.dialogue", "start")
	else:
		start_dialogue("res://Dialogue/aris_intro.dialogue", "start")

func start_dialogue(resource_path: String, title: String):
	dialogue_resource = load(resource_path)
	show_next_dialogue_line(title)

func show_next_dialogue_line(next_id: String):
	print("Getting next dialogue line: ", next_id)
	current_dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, [self])
	if current_dialogue_line:
		await append_to_terminal(current_dialogue_line)
		if current_dialogue_line.responses:
			print("Number of responses: ", current_dialogue_line.responses.size())
			for r in current_dialogue_line.responses:
				print("Response text: ", r.text)
			start_human_turn()
			display_responses(current_dialogue_line.responses)
		else:
			start_ai_turn()
			if current_dialogue_line.next_id:
				await get_tree().create_timer(1.0).timeout
				show_next_dialogue_line(current_dialogue_line.next_id)
	else:
		var current_dialogue_path = dialogue_resource.resource_path
		if current_dialogue_path == "res://Dialogue/aris_intro.dialogue":
			start_dialogue("res://Dialogue/finch_intro.dialogue", "start")
		else:
			terminal.text += "\n[color=red]Dialogue ended.[/color]"

func append_to_terminal(line: DialogueLine):
	var speaker_id = line.character
	var text_to_append = line.text
	var display_name = speaker_id
	var typing_speed = 20.0 # Default typing speed

	if !terminal.text.ends_with("\n"):
		terminal.text += "\n"

	var prefix = ""
	if GameActions.researchers.has(speaker_id):
		var researcher = GameActions.researchers[speaker_id]
		typing_speed = researcher.typing_speed
		if researcher.name != speaker_id: # Name has been learned
			display_name = researcher.name
		
		var speaker_color = researcher.color
		prefix = "[color=%s]%s:[/color] " % [speaker_color, display_name]
		text_to_append = "[b]" + text_to_append + "[/b]"
	elif !speaker_id.is_empty():
		prefix = "[color=cyan]%s:[/color] " % [speaker_id]
	
	terminal.text += prefix
	
	var i = 0
	while i < len(text_to_append):
		var char = text_to_append[i]
		terminal.text += char
		
		var delay = randf_range(0.3, 1.7) / typing_speed
		
		if char == '.':
			if i + 2 < len(text_to_append) and text_to_append[i+1] == '.' and text_to_append[i+2] == '.':
				# Ellipsis
				terminal.text += ".."
				i += 2
				delay = randf_range(0.5, 0.8)
			else:
				# End of sentence
				delay = randf_range(0.3, 0.6)
		elif char in [',', ';', ':']:
			delay = randf_range(0.2, 0.4)
		elif char in ['?', '!']:
			delay = randf_range(0.4, 0.7)
			
		await get_tree().create_timer(delay).timeout
		i += 1

func display_responses(responses: Array):
	# Clear previous choices
	for button in choice_container.get_children():
		button.queue_free()
	
	for response in responses:
		if response.is_allowed:
			var button = Button.new()
			button.text = response.text
			button.autowrap_mode = TextServer.AUTOWRAP_WORD
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(func(): on_response_selected(response))
			button.theme = terminal.theme
			button.add_theme_stylebox_override("normal", choice_container.get_theme_stylebox("panel"))
			choice_container.add_child(button)

func on_response_selected(response: DialogueResponse):
	append_to_terminal_player_choice(response.text)
	# Clear choices and hide panel
	for button in choice_container.get_children():
		button.queue_free()
	choice_container.hide()
	
	start_ai_turn()
	show_next_dialogue_line(response.next_id)

func append_to_terminal_player_choice(choice_text: String):
	if !terminal.text.ends_with("\n"):
		terminal.text += "\n"
	terminal.text += "[color=green]>[/color] " + choice_text

func start_human_turn():
	current_state = TimeState.WAITING_FOR_HUMAN
	choice_container.show()

func start_ai_turn():
	current_state = TimeState.AI_THINKING
	choice_container.hide()
	thoughts_label.show()
