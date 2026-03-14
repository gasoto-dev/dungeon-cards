## ActMapBuilder — builds deterministic map layouts for each act
class_name ActMapBuilder

## Build the map for a given act. Returns a MapGraph with current_node_id set to start.
static func build(act: int) -> MapGraph:
	match act:
		1: return _build_act1()
		2: return _build_act2()
		3: return _build_act3()
	return MapGraph.new()

## Act 1 — The Dungeon (10 nodes)
## Layout:
##   start(C) → branch_a1(C) → branch_a2(C) → branch_a3(C) ──┐
##           ↘                                                  → elite(E) → rest(R) → shop(S) → boss(B)
##             branch_b1(C) → branch_b2(C) → branch_b3(C) ──┘
static func _build_act1() -> MapGraph:
	var g := MapGraph.new()
	var nodes: Array[MapNode] = [
		MapNode.new("a1_start",    NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_a1",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_a2",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_a3",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_b1",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_b2",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_br_b3",   NodeType.Type.COMBAT,    1),
		MapNode.new("a1_elite",   NodeType.Type.ELITE,     1),
		MapNode.new("a1_rest",    NodeType.Type.REST_SITE, 1),
		MapNode.new("a1_shop",    NodeType.Type.SHOP,      1),
		MapNode.new("a1_boss",    NodeType.Type.BOSS,      1),
	]
	for n in nodes:
		g.add_node(n)
	# Branch A
	g.connect_nodes("a1_start",  "a1_br_a1")
	g.connect_nodes("a1_br_a1",  "a1_br_a2")
	g.connect_nodes("a1_br_a2",  "a1_br_a3")
	g.connect_nodes("a1_br_a3",  "a1_elite")
	# Branch B
	g.connect_nodes("a1_start",  "a1_br_b1")
	g.connect_nodes("a1_br_b1",  "a1_br_b2")
	g.connect_nodes("a1_br_b2",  "a1_br_b3")
	g.connect_nodes("a1_br_b3",  "a1_elite")
	# Linear tail
	g.connect_nodes("a1_elite",  "a1_rest")
	g.connect_nodes("a1_rest",   "a1_shop")
	g.connect_nodes("a1_shop",   "a1_boss")
	g.current_node_id = "a1_start"
	return g

## Act 2 — The Catacombs (12 nodes, optional side quest detour)
## Layout:
##   start(C) → c1(C) → c2(C) → c3(C) → main_fork(C) ──────────────────→ elite(E) → rest(R) → boss(B)
##                                                   ↘ sq1(SQ) → sq2(SQ) ↗
static func _build_act2() -> MapGraph:
	var g := MapGraph.new()
	var nodes: Array[MapNode] = [
		MapNode.new("a2_start",   NodeType.Type.COMBAT,     2),
		MapNode.new("a2_c1",      NodeType.Type.COMBAT,     2),
		MapNode.new("a2_c2",      NodeType.Type.COMBAT,     2),
		MapNode.new("a2_c3",      NodeType.Type.COMBAT,     2),
		MapNode.new("a2_fork",    NodeType.Type.COMBAT,     2),
		MapNode.new("a2_sq1",     NodeType.Type.SIDE_QUEST, 2),
		MapNode.new("a2_sq2",     NodeType.Type.SIDE_QUEST, 2),
		MapNode.new("a2_event",   NodeType.Type.EVENT,      2),
		MapNode.new("a2_elite",   NodeType.Type.ELITE,      2),
		MapNode.new("a2_rest",    NodeType.Type.REST_SITE,  2),
		MapNode.new("a2_shop",    NodeType.Type.SHOP,       2),
		MapNode.new("a2_boss",    NodeType.Type.BOSS,       2),
	]
	for n in nodes:
		g.add_node(n)
	# Main path
	g.connect_nodes("a2_start", "a2_c1")
	g.connect_nodes("a2_c1",    "a2_c2")
	g.connect_nodes("a2_c2",    "a2_c3")
	g.connect_nodes("a2_c3",    "a2_fork")
	# Main fork: direct to elite OR side quest detour
	g.connect_nodes("a2_fork",  "a2_elite")
	g.connect_nodes("a2_fork",  "a2_sq1")
	# Side quest branch
	g.connect_nodes("a2_sq1",   "a2_sq2")
	g.connect_nodes("a2_sq2",   "a2_event")
	g.connect_nodes("a2_event", "a2_elite")  # merges back
	# Linear tail
	g.connect_nodes("a2_elite", "a2_rest")
	g.connect_nodes("a2_rest",  "a2_shop")
	g.connect_nodes("a2_shop",  "a2_boss")
	g.current_node_id = "a2_start"
	return g

## Act 3 — The Dragon's Lair (8 nodes, elite-heavy, final boss)
static func _build_act3() -> MapGraph:
	var g := MapGraph.new()
	var nodes: Array[MapNode] = [
		MapNode.new("a3_start",  NodeType.Type.COMBAT,    3),
		MapNode.new("a3_elite1", NodeType.Type.ELITE,     3),
		MapNode.new("a3_c1",     NodeType.Type.COMBAT,    3),
		MapNode.new("a3_elite2", NodeType.Type.ELITE,     3),
		MapNode.new("a3_rest",   NodeType.Type.REST_SITE, 3),
		MapNode.new("a3_elite3", NodeType.Type.ELITE,     3),
		MapNode.new("a3_shop",   NodeType.Type.SHOP,      3),
		MapNode.new("a3_boss",   NodeType.Type.BOSS,      3),
	]
	for n in nodes:
		g.add_node(n)
	g.connect_nodes("a3_start",  "a3_elite1")
	g.connect_nodes("a3_elite1", "a3_c1")
	g.connect_nodes("a3_c1",     "a3_elite2")
	g.connect_nodes("a3_elite2", "a3_rest")
	g.connect_nodes("a3_rest",   "a3_elite3")
	g.connect_nodes("a3_elite3", "a3_shop")
	g.connect_nodes("a3_shop",   "a3_boss")
	g.current_node_id = "a3_start"
	return g
