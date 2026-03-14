## MapNode — a single node on the dungeon map
class_name MapNode
extends Resource

var id: String = ""
var type: NodeType.Type = NodeType.Type.COMBAT
var act: int = 1
var connections: Array[String] = []  # ids of reachable next nodes
var visited: bool = false

func _init(p_id: String = "", p_type: NodeType.Type = NodeType.Type.COMBAT,
		p_act: int = 1) -> void:
	id = p_id
	type = p_type
	act = p_act
