extends Resource

class_name TestQuestion

enum QuestionType { TEXT, IMAGE, AUDIO, FREE_TEXT }

@export var question_type: QuestionType = QuestionType.TEXT
@export_multiline var question_text: String = ""
@export var asset_path: String = "" # For IMAGE or AUDIO questions
@export var answers: Array[AnswerOption] = []
@export var keywords: Array[String] = [] # For FREE_TEXT, which will have its own scoring
@export var free_text_iq_effect: float = 0.0
@export var free_text_eq_effect: float = 0.0
@export var free_text_suspicion_effect: float = 0.0
