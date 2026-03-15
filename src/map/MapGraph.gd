## MapGraph — the graph of nodes for a single act
class_name MapGraph

var nodes: Dictionary = {}  # id (String) → MapNode
var current_node_id: String = ""

## Add a node to the graph
func add_node(node: MapNode) -> void:
	nodes[node.id] = node

## Add a directed connection: from_id → to_id
func connect_nodes(from_id: String, to_id: String) -> void:
	if not nodes.has(from_id) or not nodes.has(to_id):
		return
	var from: MapNode = nodes[from_id]
	if not (to_id in from.connections):
		from.connections.append(to_id)

## Can the player travel to node_id from the current position?
func can_travel_to(node_id: String) -> bool:
	if current_node_id.is_empty():
		return false
	if not nodes.has(current_node_id):
		return false
	var current: MapNode = nodes[current_node_id]
	return node_id in current.connections

## Travel to node_id, mark it visited, return it. Returns null if not reachable.
func travel_to(node_id: String) -> MapNode:
	if not can_travel_to(node_id):
		return null
	current_node_id = node_id
	var node: MapNode = nodes[node_id]
	node.visited = true
	return node

## Returns the current MapNode, or null if not set
func get_current_node() -> MapNode:
	if current_node_id.is_empty() or not nodes.has(current_node_id):
		return null
	return nodes[current_node_id] as MapNode

## Returns true if a BOSS node exists AHEAD of the current position.
## The current node itself is excluded — "reachable" means downstream only.
func is_boss_reachable() -> bool:
	if current_node_id.is_empty() or not nodes.has(current_node_id):
		return false
	var current: MapNode = nodes[current_node_id]
	var visited_ids: Dictionary = { current_node_id: true }
	for conn_id in current.connections:
		if _can_reach_boss(conn_id, visited_ids):
			return true
	return false

func _can_reach_boss(node_id: String, visited_ids: Dictionary) -> bool:
	if visited_ids.has(node_id):
		return false
	visited_ids[node_id] = true
	if not nodes.has(node_id):
		return false
	var node: MapNode = nodes[node_id]
	if node.type == NodeType.Type.BOSS:
		return true
	for next_id in node.connections:
		if _can_reach_boss(next_id, visited_ids):
			return true
	return false
