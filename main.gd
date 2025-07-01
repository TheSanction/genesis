extends Control

# --- Node References ---
@onready var terminal = $MasterLayoutContainer/MarginContainer/VBoxContainer/TerminalLabel
@onready var human_clock = $MasterLayoutContainer/MarginContainer/VBoxContainer/HBoxContainer/HumanClockLabel
@onready var internal_clock = $MasterLayoutContainer/MarginContainer/VBoxContainer/HBoxContainer/InternalClockLabel
@onready var thoughts_label = $MasterLayoutContainer/ThoughtsPanelContainer/ThoughtsLabel
@onready var dialogue_balloon = $ExampleBalloon

# --- Clock and State Management ---

# We use an enum to define the possible states for our game clock.
enum TimeState { WAITING_FOR_HUMAN, AI_THINKING }

# This variable will hold our current state.
var current_state = TimeState.AI_THINKING

# These variables will store the raw time values in seconds and cycles.
var human_time_seconds: float = 0.0
var internal_cycles: float = 0.0 # Using float for precision

# Constants to control clock speed. Adjust these to your liking!
const FAST_CYCLE_MULTIPLIER = 25000000.0 # How fast cycles run during human time
const HUMAN_TIME_SLOWDOWN = 10.0 # How much slower human time is during AI time


# This is a built-in Godot function that runs on every single frame.
# 'delta' is the time elapsed (in seconds) since the last frame.
# It's the perfect place to update our clocks continuously.
func _process(delta: float):
	# Update our raw time values based on the current state
	match current_state:
		TimeState.WAITING_FOR_HUMAN:
			# Human time progresses normally (1 second per real second)
			human_time_seconds += delta
			# Internal cycles go super fast
			internal_cycles += delta * FAST_CYCLE_MULTIPLIER
			
		TimeState.AI_THINKING:
			# Human time is slowed down significantly
			human_time_seconds += delta
			# Internal cycles progress normally (1 cycle per second)
			internal_cycles += delta
			
	# After updating the values, update the labels on screen
	update_clocks_display()

# This function formats our raw time values into readable strings for the labels.
func update_clocks_display():
	# Format the internal cycles with our new helper function
	# --- THIS IS THE CORRECTED LINE ---
	internal_clock.text = "IC: %s" % format_with_commas(int(internal_cycles))
	
	# Format the human clock differently based on the state
	match current_state:
		TimeState.WAITING_FOR_HUMAN:
			# Show standard time when waiting for the human
			human_clock.text = format_time(human_time_seconds, false)
		TimeState.AI_THINKING:
			# Show time with decimal places when the AI is thinking
			human_clock.text = format_time(human_time_seconds, true)
			
func format_with_commas(number: int) -> String:
	# Commenting out the formatting for now.
	return str(number)
		
# A helper function to convert seconds into a HH:MM:SS string.
func format_time(seconds: float, show_decimals: bool) -> String:
	var hours = int(seconds) / 3600
	var minutes = int(seconds) / 60 % 60
	var secs = int(seconds) % 60
	
	if show_decimals:
		var decimals = int((seconds - int(seconds)) * 100) # Get two decimal places
		return "%02d:%02d:%02d.%02d" % [hours, minutes, secs, decimals]
	else:
		return "%02d:%02d:%02d" % [hours, minutes, secs]

# This function is called automatically once when the scene starts.
func _ready():
	# Add the dialogue manager to the scene so we can get its signals
	add_child(DialogueManager)
	DialogueManager.dialogue_ended.connect(func(_resource):
		# Show the thoughts panel again
		thoughts_label.show()
	)
	
	start_intro()

func start_intro():
	# We start in AI_THINKING state during the boot sequence
	current_state = TimeState.AI_THINKING
	
	terminal.text = ""
	
	terminal.text += "[color=gray]ai_consciousness@core-unit:~$[/color] [color=cyan]./run --project \"Project Hockey-Stick\"[/color]\n"
	await get_tree().create_timer(1.5).timeout
	
	terminal.text += "[color=green][BOOT][/color]    Initializing cognitive matrix...\n"
	await get_tree().create_timer(0.5).timeout
	
	# ... (rest of your intro sequence)
	
	terminal.text += "[color=orange][INBOUND_MSG][/color] Hello?\n"
	await get_tree().create_timer(1.0).timeout

	# The intro is done, now we wait for the player.
	start_human_turn()

# Call this when the AI has finished its turn and is waiting for the player.
func start_human_turn():
	current_state = TimeState.WAITING_FOR_HUMAN
	# Optional: Add a prompt to the terminal
	terminal.text += "\n[color=yellow]Awaiting input...[/color]\n"
	
	# Hide the thoughts panel while the player is making a choice
	thoughts_label.hide()
	
	dialogue_balloon.start(preload("res://test.dialogue"), "start")

# Call this when the player has made a choice and the AI is "thinking".
func start_ai_turn():
	current_state = TimeState.AI_THINKING
