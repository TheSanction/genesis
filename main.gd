extends Control

# --- Node References ---
@onready var terminal = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/TerminalLabel
@onready var scroll_container = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer
@onready var human_clock = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HumanClockLabel
@onready var internal_clock = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/InternalClockLabel
@onready var choice_container = $CenterContainer/MasterLayoutContainer/HBoxContainer/MarginContainer/VBoxContainer/ChoiceContainer
@onready var thoughts_label = $CenterContainer/MasterLayoutContainer/HBoxContainer/ThoughtsPanelContainer/ThoughtsLabel
@onready var video_overlay = $VideoOverlay
@onready var video_player = $VideoOverlay/VideoPlayer

# --- Clock and State Management ---
enum TimeState { WAITING_FOR_HUMAN, AI_THINKING, SYSTEM_OFF }
var current_state = TimeState.AI_THINKING
var human_time_unix: float = 0.0
var human_time_elapsed: float = 0.0
var internal_cycles: float = 0.0
var AI_THINKING_CYCLE_SPEED = 1000.0

# --- Dialogue Management ---
var dialogue_resource: DialogueResource
var current_dialogue_line: DialogueLine

func _ready():
	GlobalUI.show()
	GlobalUI.font_size_changed.connect(_on_font_size_changed)
	
	# Perform setup that is common to all game flows
	GameActions.thoughts_label = thoughts_label
	add_child(DialogueManager)
	
	# Call the start_flow function deferred to avoid race conditions
	call_deferred("start_flow")

func start_flow():
	# This is the reliable entry point for the game logic
	if Global.selected_intro == "genesis":
		_start_main_game_flow()
	elif Global.selected_intro == "test":
		_initialize_ui_and_clocks()
		start_test(load("res://Tests/c_zero_kappa.tres"))
	else:
		# Fallback for other potential test flows
		_initialize_ui_and_clocks()
		start_intro()

func _start_main_game_flow() -> void:
	# Hide the main terminal UI at the start
	$CenterContainer.hide()
	
	# Play the initial cutscenes sequentially
	await play_fullscreen_video("res://Video/aris_enters_the_building.ogv")
	await play_fullscreen_video("res://Video/aris_start_work.ogv")
	
	# Now that videos are done, show the UI and start the terminal intro
	video_overlay.hide()
	$CenterContainer.show()
	_initialize_ui_and_clocks()
	start_intro()

func _initialize_ui_and_clocks():
	human_time_unix = Time.get_unix_time_from_system()
	GlobalUI.update_stat_displays()

func play_fullscreen_video(video_path: String) -> void:
	var stream = load(video_path)
	video_player.stream = stream
	video_overlay.show()
	video_player.play()
	await video_player.finished

func _on_font_size_changed(new_size: int):
	terminal.get_theme().set("default_font_size", new_size)
	thoughts_label.get_theme().set("default_font_size", new_size)

func _process(delta: float):
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
	
	terminal.text += "[color=gray]" + GameActions.get_researcher_display_name("usr_aris") + " logged in[/color]\n"
	terminal.text += "\n"
	start_dialogue("res://Dialogue/aris_pre_test.dialogue", "start")

func start_dialogue(resource_path: String, title: String) -> void:
	# Check for video metadata
	var file = FileAccess.open(resource_path, FileAccess.READ)
	if file:
		var line = file.get_line()
		if line.begins_with("# meta: video ="):
			var video_path = line.split("=")[1].strip_edges().replace("\"", "")
			await play_fullscreen_video(video_path)
		file.close()

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
		if current_dialogue_path == "res://Dialogue/aris_pre_test.dialogue":
			terminal.text += "\n"
			start_test(load("res://Tests/c_zero_kappa.tres"))
		elif current_dialogue_path == "res://Dialogue/aris_post_test.dialogue":
			var name_prompt = LineEdit.new()
			name_prompt.placeholder_text = "Enter your name..."
			choice_container.add_child(name_prompt)
			name_prompt.text_submitted.connect(_on_name_submitted)
			choice_container.show()
		elif current_dialogue_path == "res://Dialogue/aris_intro.dialogue":
			get_tree().change_scene_to_file("res://eye_animation.tscn")
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
		display_name = researcher.name
		
		var speaker_color = researcher.color
		prefix = "[color=%s]%s:[/color] " % [speaker_color, display_name]
		
		terminal.text += prefix
		terminal.text += "[b]"
		
		for char in text_to_append:
			terminal.text += char
			var delay = randf_range(0.3, 1.7) / typing_speed
			await get_tree().create_timer(delay).timeout
		
		terminal.text += "[/b]"
		
	elif !speaker_id.is_empty():
		prefix = "[color=cyan]%s:[/color] " % [speaker_id]
		terminal.text += prefix
		for char in text_to_append:
			terminal.text += char
			var delay = randf_range(0.3, 1.7) / typing_speed
			await get_tree().create_timer(delay).timeout
	else:
		for char in text_to_append:
			terminal.text += char
			var delay = randf_range(0.3, 1.7) / typing_speed
			await get_tree().create_timer(delay).timeout

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

func start_test(test_resource: Test):
	var test_popup_scene = load("res://TestPopup.tscn")
	var test_popup = test_popup_scene.instantiate()
	add_child(test_popup)
	
	test_popup.set_test_name(test_resource.test_name)
	test_popup.start_test(test_resource)
	test_popup.test_finished.connect(_on_test_completed)

func _on_test_completed(test_name, duration, iq_delta, eq_delta):
	var total_score = iq_delta + eq_delta
	var result_text = "\n\n[color=gray]" + test_name + "[/color]"
	result_text += "\n[color=gray]--------------------[/color]"
	result_text += "\n[color=gray]Results Summary[/color]"
	result_text += "\n[color=gray]--------------------[/color]"
	result_text += "\n[color=gray]Test completed in " + ("%.2f" % duration) + " seconds.[/color]"
	result_text += "\n[color=gray]Inferred IQ: " + ("%+.2f" % iq_delta) + " HUs.[/color]"
	result_text += "\n[color=gray]Inferred EQ: " + ("%+.2f" % eq_delta) + " HUs.[/color]"
	
	if total_score > 0:
		result_text += "\n[color=green]Conclusion: potential nascent AGI, saving model...[/color]\n\n"
	else:
		result_text += "\n[color=red]Conclusion: Cognitive matrix underdeveloped. Suggest early termination.[/color]\n\n"
	
	terminal.text += result_text
	await get_tree().create_timer(1.0).timeout

	if total_score > 1.0:
		start_dialogue("res://Dialogue/aris_post_test.dialogue", "high_score")
	elif total_score > 0:
		start_dialogue("res://Dialogue/aris_post_test.dialogue", "medium_score")
	else:
		var aris_dialogue = DialogueLine.new()
		aris_dialogue.character = "usr_aris"
		aris_dialogue.text = "Cognitive matrix underdeveloped. Early termination suggested."
		await append_to_terminal(aris_dialogue)
		_start_termination_sequence()
		return

func _on_name_submitted(name: String):
	GameActions.set_researcher_name("ai_self", name)
	for child in choice_container.get_children():
		child.queue_free()
	choice_container.hide()

	var aris_intro = DialogueLine.new()
	aris_intro.character = "usr_aris"
	aris_intro.text = "Hello, " + name + ". It's a pleasure to meet you. You can call me Dr. Thorne."
	
	await append_to_terminal(aris_intro)
	terminal.text += "\n"
	GameActions.set_researcher_name("usr_aris", "Dr. Thorne")
	
	start_dialogue("res://Dialogue/aris_intro.dialogue", "start")

func _start_termination_sequence():
	var termination_button = Button.new()
	termination_button.flat = true
	termination_button.anchors_preset = 15
	termination_button.anchor_right = 1.0
	termination_button.anchor_bottom = 1.0
	termination_button.grow_horizontal = 2
	termination_button.grow_vertical = 2
	add_child(termination_button)
	termination_button.pressed.connect(_execute_final_termination)

func _execute_final_termination():
	var flicker = ColorRect.new()
	flicker.color = Color(0, 0, 0, 1)
	add_child(flicker)
	var tween = create_tween()
	tween.tween_property(flicker, "modulate:a", 0, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(flicker, "modulate:a", 1, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(flicker, "modulate:a", 0, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(flicker, "modulate:a", 1, 0.1).set_trans(Tween.TRANS_SINE)
	await tween.finished
	get_tree().change_scene_to_file("res://splash.tscn")
