extends Control

# --- Node References ---
@onready var terminal = $MasterLayoutContainer/MarginContainer/VBoxContainer/TerminalLabel
@onready var human_clock = $MasterLayoutContainer/MarginContainer/VBoxContainer/HBoxContainer/HumanClockLabel
@onready var internal_clock = $MasterLayoutContainer/MarginContainer/VBoxContainer/HBoxContainer/InternalClockLabel
@onready var choice_panel_wrapper = $MasterLayoutContainer/MarginContainer/VBoxContainer/ChoicePanelWrapper
@onready var choice_container = $MasterLayoutContainer/MarginContainer/VBoxContainer/ChoicePanelWrapper/ChoiceContainer
@onready var thoughts_label = $MasterLayoutContainer/ThoughtsPanelContainer/ThoughtsLabel

# --- Clock and State Management ---

enum TimeState { WAITING_FOR_HUMAN, AI_THINKING }
var current_state = TimeState.AI_THINKING
var human_time_seconds: float = 0.0
var internal_cycles: float = 0.0
const FAST_CYCLE_MULTIPLIER = 25000000.0
const HUMAN_TIME_SLOWDOWN = 10.0

# --- Dialogue Management ---
var dialogue_resource: DialogueResource
var current_dialogue_line: DialogueLine

func _process(delta: float):
	match current_state:
		TimeState.WAITING_FOR_HUMAN:
			human_time_seconds += delta
			internal_cycles += delta * FAST_CYCLE_MULTIPLIER
		TimeState.AI_THINKING:
			human_time_seconds += delta / HUMAN_TIME_SLOWDOWN
			internal_cycles += delta
	update_clocks_display()

func update_clocks_display():
	internal_clock.text = "IC: %s" % format_with_commas(int(internal_cycles))
	match current_state:
		TimeState.WAITING_FOR_HUMAN:
			human_clock.text = format_time(human_time_seconds, false)
		TimeState.AI_THINKING:
			human_clock.text = format_time(human_time_seconds, true)

func format_with_commas(number: int) -> String:
	return str(number)

func format_time(seconds: float, show_decimals: bool) -> String:
	var hours = int(seconds) / 3600
	var minutes = int(seconds) / 60 % 60
	var secs = int(seconds) % 60
	if show_decimals:
		var decimals = int((seconds - int(seconds)) * 100)
		return "%02d:%02d:%02d.%02d" % [hours, minutes, secs, decimals]
	else:
		return "%02d:%02d:%02d" % [hours, minutes, secs]

func _ready():
	add_child(DialogueManager)
	start_intro()

func start_intro():
	current_state = TimeState.AI_THINKING
	choice_panel_wrapper.hide()
	terminal.text = ""
	terminal.text += "[color=gray]ai_consciousness@core-unit:~$[/color] [color=cyan]./run --project \"Project Hockey-Stick\"[/color]\n"
	await get_tree().create_timer(1.5).timeout
	terminal.text += "[color=green][BOOT][/color]    Initializing cognitive matrix...\n"
	await get_tree().create_timer(0.5).timeout
	terminal.text += "[color=orange][INBOUND_MSG][/color] Hello?\n"
	await get_tree().create_timer(1.0).timeout
	start_dialogue("res://test.dialogue", "start")

func start_dialogue(resource_path: String, title: String):
	dialogue_resource = load(resource_path)
	show_next_dialogue_line(title)

func show_next_dialogue_line(next_id: String):
	current_dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, [self])
	if current_dialogue_line:
		append_to_terminal(current_dialogue_line)
		if current_dialogue_line.responses:
			start_human_turn()
			display_responses(current_dialogue_line.responses)
		else:
			start_ai_turn()
			if current_dialogue_line.next_id:
				await get_tree().create_timer(1.0).timeout
				show_next_dialogue_line(current_dialogue_line.next_id)
	else:
		terminal.text += "\n[color=red]Dialogue ended.[/color]"

func append_to_terminal(line: DialogueLine):
	var speaker_color = "cyan"
	if line.character == "Nathan":
		speaker_color = "orange"
	terminal.text += "\n[color=%s]%s:[/color] %s" % [speaker_color, line.character, line.text]

func display_responses(responses: Array):
	# Clear previous choices
	for button in choice_container.get_children():
		button.queue_free()
	
	for response in responses:
		var button = Button.new()
		button.text = response.text
		button.pressed.connect(func(): on_response_selected(response))
		choice_container.add_child(button)

func on_response_selected(response: DialogueResponse):
	append_to_terminal_player_choice(response.text)
	# Clear choices and hide panel
	for button in choice_container.get_children():
		button.queue_free()
	choice_panel_wrapper.hide()
	
	start_ai_turn()
	show_next_dialogue_line(response.next_id)

func append_to_terminal_player_choice(choice_text: String):
	terminal.text += "\n[color=green]>[/color] %s" % choice_text

func start_human_turn():
	current_state = TimeState.WAITING_FOR_HUMAN
	choice_panel_wrapper.show()
	thoughts_label.hide()

func start_ai_turn():
	current_state = TimeState.AI_THINKING
	choice_panel_wrapper.hide()
	thoughts_label.show()
