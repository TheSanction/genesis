extends Node2D

signal puzzle_completed(score)

@onready var camera = $Camera2D
@onready var throughput_label = $UI/VBoxContainer/ThroughputLabel
@onready var packet_loss_label = $UI/VBoxContainer/PacketLossLabel

# Preload assets and scenes
const CELL_SCENE = preload("res://cell.tscn")
const GRID_TEXTURE = preload("res://Puzzles/Assets/grid_cell.png")
const STARTPOINT_TEXTURE = preload("res://Puzzles/Assets/information_flow_startpoint.png")
const ENDPOINT_TEXTURE = preload("res://Puzzles/Assets/information_flow_endpoint.png")
const PACKET_LOSS_TEXTURE = preload("res://Puzzles/Assets/packet_loss_endpoint.png")
const CIRCUIT_TEXTURE = preload("res://Puzzles/Assets/circuit_four_straight_edges.png")
const FLOW_SIMULATOR = preload("res://FlowSimulator.gd")
const PUZZLE_GENERATOR = preload("res://PuzzleGenerator.gd")

const TILE_SIZE = 64

var puzzle_data: PuzzleData
var placed_circuits = {} # Key: Vector2i, Value: { "node": Node2D, "rotation": 0 }
var endpoint_sprites = {} # Use a dictionary to track sprites by position
var flow_simulator
var throughput = 0
var packet_loss = 0

# This function is now the entry point for the puzzle
func initialize(width: int, height: int):
	print("--- Initializing puzzle with size: ", Vector2i(width, height), " ---")
	var puzzle_generator = PUZZLE_GENERATOR.new()
	puzzle_data = puzzle_generator.generate(width, height)
	
	flow_simulator = FLOW_SIMULATOR.new()
	
	print("--- Data generated. Drawing grid. ---")
	draw_grid()
	
	call_deferred("center_camera")

func _input(event):
	if !puzzle_data: return # Don't allow input until initialized

	if event is InputEventMouseButton and event.pressed:
		var grid_pos = _world_to_grid(event.position)
		
		if grid_pos.x < 0 or grid_pos.x >= puzzle_data.grid_size.x or grid_pos.y < 0 or grid_pos.y >= puzzle_data.grid_size.y:
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			place_circuit(grid_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			remove_circuit(grid_pos)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			rotate_circuit(grid_pos)
		
		run_simulation()

func _world_to_grid(screen_pos):
	var world_pos = get_global_mouse_position()
	var grid_x = floor(world_pos.x / TILE_SIZE)
	var grid_y = floor(world_pos.y / TILE_SIZE)
	return Vector2i(grid_x, grid_y)

func place_circuit(grid_pos):
	if placed_circuits.has(grid_pos) or endpoint_sprites.has(grid_pos):
		return

	var new_circuit_node = CELL_SCENE.instantiate()
	new_circuit_node.texture = CIRCUIT_TEXTURE
	new_circuit_node.position = Vector2(grid_pos.x * TILE_SIZE, grid_pos.y * TILE_SIZE)
	
	var texture_size = new_circuit_node.texture.get_size()
	if texture_size.x != 0:
		new_circuit_node.scale = Vector2(float(TILE_SIZE) / texture_size.x, float(TILE_SIZE) / texture_size.y)
		
	add_child(new_circuit_node)
	placed_circuits[grid_pos] = { "node": new_circuit_node, "rotation": 0 }

func remove_circuit(grid_pos):
	if placed_circuits.has(grid_pos):
		placed_circuits[grid_pos]["node"].queue_free()
		placed_circuits.erase(grid_pos)

func rotate_circuit(grid_pos):
	if placed_circuits.has(grid_pos):
		var circuit = placed_circuits[grid_pos]
		circuit["rotation"] = (circuit["rotation"] + 90) % 360
		circuit["node"].rotation_degrees = circuit["rotation"]
		print("Rotated circuit at ", grid_pos, " to ", circuit["rotation"], " degrees")


func run_simulation():
	var graph = flow_simulator.build_graph(placed_circuits)
	var flow_result = flow_simulator.calculate_flow(graph, placed_circuits, puzzle_data.start_edges, puzzle_data.target_edges, puzzle_data.anti_edges)
	
	var connected_targets = flow_result["connected_targets"]
	var connected_losses = flow_result["connected_losses"]
	
	throughput = connected_targets.size()
	
	if puzzle_data.anti_edges.size() > 0:
		packet_loss = (float(connected_losses.size()) / puzzle_data.anti_edges.size()) * 100
	else:
		packet_loss = 0

	throughput_label.text = "Throughput: " + str(throughput)
	packet_loss_label.text = "Packet Loss: " + ("%d" % packet_loss) + "%"
	
	for pos in endpoint_sprites.keys():
		var sprite = endpoint_sprites[pos]
		if connected_targets.has(pos):
			sprite.modulate = Color.BLUE
		elif connected_losses.has(pos):
			sprite.modulate = Color.RED
		else:
			sprite.modulate = Color.WHITE
			
func draw_grid():
	for y in range(puzzle_data.grid_size.y):
		for x in range(puzzle_data.grid_size.x):
			var new_cell = CELL_SCENE.instantiate()
			new_cell.texture = GRID_TEXTURE
			new_cell.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			var texture_size = new_cell.texture.get_size()
			if texture_size.x != 0: new_cell.scale = Vector2(float(TILE_SIZE) / texture_size.x, float(TILE_SIZE) / texture_size.y)
			add_child(new_cell)

	for pos in puzzle_data.start_edges:
		_create_endpoint_sprite(pos, STARTPOINT_TEXTURE)
	for pos in puzzle_data.target_edges:
		_create_endpoint_sprite(pos, ENDPOINT_TEXTURE)
	for pos in puzzle_data.anti_edges:
		_create_endpoint_sprite(pos, PACKET_LOSS_TEXTURE)
	
	print("--- Grid drawn. ---")

func _create_endpoint_sprite(pos: Vector2i, texture: Texture):
	var endpoint_cell = CELL_SCENE.instantiate()
	endpoint_cell.texture = texture
	endpoint_cell.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
	var texture_size = endpoint_cell.texture.get_size()
	if texture_size.x != 0: endpoint_cell.scale = Vector2(float(TILE_SIZE) / texture_size.x, float(TILE_SIZE) / texture_size.y)
	add_child(endpoint_cell)
	endpoint_sprites[pos] = endpoint_cell

func center_camera():
	var grid_pixel_size = puzzle_data.grid_size * TILE_SIZE
	camera.position = (Vector2(grid_pixel_size) / 2) - Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	camera.zoom = Vector2(2.0, 2.0)
	print("--- Camera centered and zoomed. Puzzle ready. ---")
