## RunManager — manages the overall run state across all acts
class_name RunManager

var current_act: int = 1
var map: MapGraph
var player: Player

signal node_entered(node: MapNode)

func _init(p_player: Player = null) -> void:
	player = p_player if p_player != null else Player.new()

## Initialize Act 1 map, place player at start node
func start_run() -> void:
	current_act = 1
	map = ActMapBuilder.build(current_act)
	var start := map.get_current_node()
	if start:
		start.visited = true

## Travel to a node and emit node_entered
func enter_node(node_id: String) -> void:
	var node := map.travel_to(node_id)
	if node:
		node_entered.emit(node)

## Get all nodes reachable from current position
func get_available_nodes() -> Array[MapNode]:
	var current := map.get_current_node()
	if current == null:
		return []
	var result: Array[MapNode] = []
	for conn_id in current.connections:
		if map.nodes.has(conn_id):
			result.append(map.nodes[conn_id] as MapNode)
	return result

## Advance to the next act — builds a fresh map, resets current position
func advance_to_next_act() -> void:
	current_act += 1
	map = ActMapBuilder.build(current_act)
	var start := map.get_current_node()
	if start:
		start.visited = true
