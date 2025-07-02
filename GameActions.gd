extends Node

var thoughts_label: RichTextLabel

func set_ai_thought(thought: String):
	if thoughts_label:
		print("Setting thought: ", thought)
		thoughts_label.text = thought
		thoughts_label.get_parent().show()
	else:
		print("Error: thoughts_label not set in GameActions.")
