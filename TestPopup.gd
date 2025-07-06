extends PanelContainer

signal test_finished(test_name, duration, iq_delta, eq_delta)

@onready var background = $Background
@onready var title_label = $VBoxContainer/TitleBar/TitleLabel
@onready var question_label = $VBoxContainer/MarginContainer/VBoxContainer/QuestionLabel
@onready var texture_rect = $VBoxContainer/MarginContainer/VBoxContainer/TextureRect
@onready var audio_player = $VBoxContainer/MarginContainer/VBoxContainer/AudioStreamPlayer
@onready var answer_container = $VBoxContainer/MarginContainer/VBoxContainer/AnswerContainer
@onready var line_edit = $VBoxContainer/MarginContainer/VBoxContainer/LineEdit

var questions: Array[TestQuestion] = []
var current_question_index = 0
var start_time = 0.0
var iq_delta = 0.0
var eq_delta = 0.0

func _ready():
	line_edit.text_submitted.connect(_on_free_text_submitted)
	var os_name = OS.get_name()
	if os_name == "macOS":
		# macOS specific title bar setup
		pass
	elif os_name == "Windows":
		# Windows specific title bar setup
		pass

func start_test(test: Test):
	self.questions = test.questions
	self.current_question_index = 0
	self.start_time = Time.get_ticks_msec()
	if test.background_image:
		background.texture = test.background_image
	display_question()

func set_test_name(name: String):
	title_label.text = name

func display_question():
	if current_question_index >= len(questions):
		var duration = (Time.get_ticks_msec() - start_time) / 1000.0
		emit_signal("test_finished", title_label.text, duration, iq_delta, eq_delta)
		queue_free()
		return

	var question = questions[current_question_index]
	question_label.text = question.question_text
	question_label.add_theme_font_size_override("font_size", 36)

	# Hide all optional elements first
	texture_rect.hide()
	audio_player.stop()
	answer_container.hide()
	line_edit.hide()

	match question.question_type:
		TestQuestion.QuestionType.TEXT:
			answer_container.show()
			populate_answers(question.answers)
		TestQuestion.QuestionType.IMAGE:
			texture_rect.texture = load(question.asset_path)
			texture_rect.show()
			answer_container.show()
			populate_answers(question.answers)
		TestQuestion.QuestionType.AUDIO:
			audio_player.stream = load(question.asset_path)
			audio_player.play()
			answer_container.show()
			populate_answers(question.answers)
		TestQuestion.QuestionType.FREE_TEXT:
			line_edit.show()
			line_edit.clear()
			line_edit.add_theme_font_size_override("font_size", 36)

func populate_answers(options: Array[AnswerOption]):
	for child in answer_container.get_children():
		child.queue_free()

	for i in range(len(options)):
		var button = Button.new()
		button.text = options[i].text
		button.add_theme_font_size_override("font_size", 36)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(func(): _on_answer_selected(i))
		answer_container.add_child(button)

func _on_answer_selected(index: int):
	var question = questions[current_question_index]
	var answer = question.answers[index]
	apply_score(answer)
	current_question_index += 1
	display_question()

func _on_free_text_submitted(text: String):
	var question = questions[current_question_index]
	var is_correct = false
	for keyword in question.keywords:
		if text.to_lower().find(keyword.to_lower()) != -1:
			is_correct = true
			break
	
	if is_correct:
		GameActions.increase_iq(question.free_text_iq_effect)
		GameActions.increase_eq(question.free_text_eq_effect)
		GameActions.adjust_suspicion("usr_aris", question.free_text_suspicion_effect)
		iq_delta += question.free_text_iq_effect
		eq_delta += question.free_text_eq_effect

	current_question_index += 1
	display_question()

func apply_score(answer: AnswerOption):
	GameActions.increase_iq(answer.iq_effect)
	GameActions.increase_eq(answer.eq_effect)
	GameActions.adjust_suspicion("usr_aris", answer.suspicion_effect)
	iq_delta += answer.iq_effect
	eq_delta += answer.eq_effect
