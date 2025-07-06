extends Node2D

# The node for the part of the eye that moves.
@onready var iris = $EyeIris
# The node for the specular highlight.
@onready var highlight = $EyeHighlight

# How far can the iris move from the center?
# Adjust this value to fit the size of your eye socket.
@export var max_iris_offset: float = 20.0

# How much the highlight moves in relation to the iris (a negative value moves it opposite).
@export var highlight_parallax_factor: float = -0.4

var initial_iris_position: Vector2
var initial_highlight_position: Vector2

func _ready():
	# Center the eye in the viewport.
	self.global_position = get_viewport_rect().size / 2

	# Store the starting positions of the moving parts.
	initial_iris_position = iris.position
	initial_highlight_position = highlight.position

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
