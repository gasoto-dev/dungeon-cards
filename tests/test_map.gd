extends GutTest

## Tests for NodeType, MapNode, MapGraph, ActMapBuilder, RunManager

# ── NodeType ──────────────────────────────────────────────────────────────────

func test_all_node_types_defined() -> void:
	assert_eq(NodeType.Type.COMBAT,     0)
	assert_eq(NodeType.Type.ELITE,      1)
	assert_eq(NodeType.Type.REST_SITE,  2)
	assert_eq(NodeType.Type.SHOP,       3)
	assert_eq(NodeType.Type.EVENT,      4)
	assert_eq(NodeType.Type.BOSS,       5)
	assert_eq(NodeType.Type.SIDE_QUEST, 6)

# ── MapNode ───────────────────────────────────────────────────────────────────

func test_map_node_fields_set_correctly() -> void:
	var node := MapNode.new("test_1", NodeType.Type.ELITE, 2)
	assert_eq(node.id, "test_1")
	assert_eq(node.type, NodeType.Type.ELITE)
	assert_eq(node.act, 2)
	assert_eq(node.connections.size(), 0)
	assert_false(node.visited)

func test_map_node_not_visited_by_default() -> void:
	var node := MapNode.new("n", NodeType.Type.COMBAT, 1)
	assert_false(node.visited)

# ── MapGraph ──────────────────────────────────────────────────────────────────

func _make_graph() -> MapGraph:
	var g := MapGraph.new()
	g.add_node(MapNode.new("a", NodeType.Type.COMBAT,    1))
	g.add_node(MapNode.new("b", NodeType.Type.COMBAT,    1))
	g.add_node(MapNode.new("c", NodeType.Type.BOSS,      1))
	g.connect_nodes("a", "b")
	g.connect_nodes("b", "c")
	g.current_node_id = "a"
	return g

func test_add_node_stores_node() -> void:
	var g := _make_graph()
	assert_true(g.nodes.has("a"))
	assert_true(g.nodes.has("b"))

func test_connect_nodes_adds_connection() -> void:
	var g := _make_graph()
	assert_true("b" in g.nodes["a"].connections)

func test_can_travel_to_adjacent_node() -> void:
	var g := _make_graph()
	assert_true(g.can_travel_to("b"))

func test_cannot_travel_to_non_adjacent_node() -> void:
	var g := _make_graph()
	assert_false(g.can_travel_to("c"))  # c is 2 hops away

func test_travel_to_updates_current_node() -> void:
	var g := _make_graph()
	g.travel_to("b")
	assert_eq(g.current_node_id, "b")

func test_travel_to_marks_node_visited() -> void:
	var g := _make_graph()
	g.travel_to("b")
	assert_true(g.nodes["b"].visited)

func test_travel_to_non_reachable_returns_null() -> void:
	var g := _make_graph()
	var result := g.travel_to("c")  # not adjacent to "a"
	assert_null(result)
	assert_eq(g.current_node_id, "a")  # position unchanged

func test_get_current_node_returns_correct_node() -> void:
	var g := _make_graph()
	var node := g.get_current_node()
	assert_not_null(node)
	assert_eq(node.id, "a")

func test_is_boss_reachable_true_when_boss_downstream() -> void:
	var g := _make_graph()
	assert_true(g.is_boss_reachable())

func test_is_boss_reachable_false_when_past_boss() -> void:
	var g := _make_graph()
	g.travel_to("b")
	g.travel_to("c")  # at boss now — no more connections
	assert_false(g.is_boss_reachable())  # boss is current, not downstream

# ── ActMapBuilder — Act 1 ────────────────────────────────────────────────────

func test_act1_has_correct_node_count() -> void:
	var g := ActMapBuilder.build(1)
	assert_eq(g.nodes.size(), 11)  # start + 3+3 branch + elite + rest + shop + boss

func test_act1_has_one_boss_node() -> void:
	var g := ActMapBuilder.build(1)
	var boss_nodes := g.nodes.values().filter(func(n): return n.type == NodeType.Type.BOSS)
	assert_eq(boss_nodes.size(), 1)

func test_act1_start_node_is_combat() -> void:
	var g := ActMapBuilder.build(1)
	var start := g.get_current_node()
	assert_eq(start.type, NodeType.Type.COMBAT)

func test_act1_boss_reachable_from_start() -> void:
	var g := ActMapBuilder.build(1)
	assert_true(g.is_boss_reachable())

func test_act1_has_two_branches_from_start() -> void:
	var g := ActMapBuilder.build(1)
	var start := g.get_current_node()
	assert_eq(start.connections.size(), 2)

func test_act1_has_elite_rest_shop_nodes() -> void:
	var g := ActMapBuilder.build(1)
	var types := g.nodes.values().map(func(n): return n.type)
	assert_true(NodeType.Type.ELITE in types)
	assert_true(NodeType.Type.REST_SITE in types)
	assert_true(NodeType.Type.SHOP in types)

# ── ActMapBuilder — Act 2 ────────────────────────────────────────────────────

func test_act2_has_correct_node_count() -> void:
	var g := ActMapBuilder.build(2)
	assert_eq(g.nodes.size(), 12)

func test_act2_has_side_quest_nodes() -> void:
	var g := ActMapBuilder.build(2)
	var sq_nodes := g.nodes.values().filter(func(n): return n.type == NodeType.Type.SIDE_QUEST)
	assert_gte(sq_nodes.size(), 2)

func test_act2_has_event_node() -> void:
	var g := ActMapBuilder.build(2)
	var event_nodes := g.nodes.values().filter(func(n): return n.type == NodeType.Type.EVENT)
	assert_gte(event_nodes.size(), 1)

func test_act2_has_boss_reachable() -> void:
	var g := ActMapBuilder.build(2)
	assert_true(g.is_boss_reachable())

# ── ActMapBuilder — Act 3 ────────────────────────────────────────────────────

func test_act3_has_correct_node_count() -> void:
	var g := ActMapBuilder.build(3)
	assert_eq(g.nodes.size(), 8)

func test_act3_has_one_boss_node() -> void:
	var g := ActMapBuilder.build(3)
	var boss_nodes := g.nodes.values().filter(func(n): return n.type == NodeType.Type.BOSS)
	assert_eq(boss_nodes.size(), 1)

func test_act3_has_elite_nodes() -> void:
	var g := ActMapBuilder.build(3)
	var elite_nodes := g.nodes.values().filter(func(n): return n.type == NodeType.Type.ELITE)
	assert_gte(elite_nodes.size(), 2)

func test_act3_boss_reachable_from_start() -> void:
	var g := ActMapBuilder.build(3)
	assert_true(g.is_boss_reachable())

# ── RunManager ────────────────────────────────────────────────────────────────

func test_start_run_initializes_act1_map() -> void:
	var rm := RunManager.new()
	rm.start_run()
	assert_eq(rm.current_act, 1)
	assert_not_null(rm.map)

func test_start_run_places_player_at_start() -> void:
	var rm := RunManager.new()
	rm.start_run()
	var node := rm.map.get_current_node()
	assert_not_null(node)
	assert_true(node.visited)

func test_enter_node_emits_node_entered_signal() -> void:
	var rm := RunManager.new()
	rm.start_run()
	var emitted_node: MapNode = null
	rm.node_entered.connect(func(n): emitted_node = n)
	var available := rm.get_available_nodes()
	assert_gt(available.size(), 0)
	rm.enter_node(available[0].id)
	assert_not_null(emitted_node)
	assert_eq(emitted_node.id, available[0].id)

func test_enter_node_updates_current_position() -> void:
	var rm := RunManager.new()
	rm.start_run()
	var available := rm.get_available_nodes()
	rm.enter_node(available[0].id)
	assert_eq(rm.map.current_node_id, available[0].id)

func test_get_available_nodes_returns_reachable_nodes() -> void:
	var rm := RunManager.new()
	rm.start_run()
	var available := rm.get_available_nodes()
	assert_gt(available.size(), 0)

func test_advance_to_next_act_increments_act() -> void:
	var rm := RunManager.new()
	rm.start_run()
	rm.advance_to_next_act()
	assert_eq(rm.current_act, 2)

func test_advance_to_next_act_builds_new_map() -> void:
	var rm := RunManager.new()
	rm.start_run()
	var act1_node_count := rm.map.nodes.size()
	rm.advance_to_next_act()
	var act2_node_count := rm.map.nodes.size()
	# Act 2 has 12 nodes vs Act 1's 11 — different maps
	assert_ne(act1_node_count, act2_node_count)
