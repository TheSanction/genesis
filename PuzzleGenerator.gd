# PuzzleGenerator.gd
class_name PuzzleGenerator
extends Resource

# Generates a new PuzzleData object with a fully populated border
func generate(width: int, height: int) -> PuzzleData:
	var new_puzzle = PuzzleData.new()
	new_puzzle.grid_size = Vector2i(width, height)
	
	# Set a single start edge
	var start_y = randi_range(1, height - 2)
	var start_edges_array: Array[Vector2i] = [Vector2i(0, start_y)]
	new_puzzle.start_edges = start_edges_array
	
	var targets: Array[Vector2i] = []
	var antis: Array[Vector2i] = []
	
	# Populate all other edge cells
	for y in range(height):
		for x in range(width):
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				var current_pos = Vector2i(x, y)
				if current_pos == new_puzzle.start_edges[0]:
					continue # Skip the start edge
				
				if randf() > 0.5:
					targets.append(current_pos)
				else:
					antis.append(current_pos)
					
	new_puzzle.target_edges = targets
	new_puzzle.anti_edges = antis
	
	return new_puzzle
