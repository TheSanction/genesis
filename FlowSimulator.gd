# FlowSimulator.gd
class_name FlowSimulator
extends Resource

# Builds a graph containing only the connections between placed circuits.
func build_graph(placed_circuits: Dictionary) -> Dictionary:
	var graph = {}
	for pos in placed_circuits.keys():
		var circuit_data = placed_circuits[pos]
		var rotation = circuit_data["rotation"]
		
		# For now, our only piece is a 4-way connector, so rotation doesn't matter yet.
		# This is where we will add logic for different circuit types.
		var neighbors = []
		var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		for dir in directions:
			var neighbor_pos = pos + dir
			if placed_circuits.has(neighbor_pos):
				neighbors.append(neighbor_pos)
		graph[pos] = neighbors
	return graph

# Finds all nodes in the graph reachable from a set of starting nodes.
func find_all_reachable_circuits(graph: Dictionary, start_circuits: Array) -> Dictionary:
	var queue = start_circuits.duplicate()
	var visited = {}
	for circuit in start_circuits:
		visited[circuit] = true

	while !queue.is_empty():
		var current = queue.pop_front()
		if graph.has(current):
			for neighbor in graph[current]:
				if !visited.has(neighbor):
					visited[neighbor] = true
					queue.append(neighbor)
	return visited

# Calculates the final flow based on the isolated circuit graph.
func calculate_flow(graph: Dictionary, placed_circuits: Dictionary, start_edges: Array, target_edges: Array, anti_edges: Array) -> Dictionary:
	# 1. Find which placed circuits are touching the start points.
	var start_circuits = []
	for pos in placed_circuits.keys():
		var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		for dir in directions:
			var neighbor_pos = pos + dir
			if start_edges.has(neighbor_pos):
				start_circuits.append(pos)
				break # Don't add the same circuit twice

	# 2. Find all circuits reachable from those starting circuits.
	var reachable_circuits = find_all_reachable_circuits(graph, start_circuits)

	# 3. Check which reachable circuits are touching the endpoints.
	var connected_targets = []
	var connected_losses = []
	for pos in reachable_circuits.keys():
		var directions = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		for dir in directions:
			var neighbor_pos = pos + dir
			if target_edges.has(neighbor_pos) and not connected_targets.has(neighbor_pos):
				connected_targets.append(neighbor_pos)
			if anti_edges.has(neighbor_pos) and not connected_losses.has(neighbor_pos):
				connected_losses.append(neighbor_pos)

	return {
		"connected_targets": connected_targets,
		"connected_losses": connected_losses
	}
