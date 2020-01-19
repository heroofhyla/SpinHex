tool
extends Area2D

export var color = 0 #setget set_color, get_color
export var clickable = true
var neighbors = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_color(int(randf() * 2 + 0.5))
	pass # Replace with function body.

func set_color(col):
	$Sprite.frame = col
	color = col
	
func get_color():
	return color
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func determine_neighbors():
	neighbors = {
		"ne": {
			"x": position.x - 32,
			"y": position.y - 56,
			"node": null
		},
		"e": {
			"x": position.x - 64,
			"y": position.y,
			"node": null
		},
		"se": {
			"x": position.x - 32,
			"y": position.y + 56,
			"node": null
		},
		"sw": {
			"x": position.x + 32,
			"y": position.y + 56,
			"node": null
		},
		"nw": {
			"x": position.x + 32,
			"y": position.y - 56,
			"node": null
		},
		"w": {
			"x": position.x + 64,
			"y": position.y,
			"node": null
		}
	}
	clickable = true
	var gems = get_tree().get_nodes_in_group("gems")
	for gem in gems:
		for neighbor in neighbors.values():
			if gem.position.x == neighbor["x"] \
			and gem.position.y == neighbor["y"]:
				neighbor["node"] = gem
	for neighbor in neighbors.values():
		if neighbor["node"] == null:
			print_debug("found a null, can't move")
			clickable = false

func rotate_neighbors():
	determine_neighbors()
	if not clickable:
		return

	var nw_pos = neighbors["nw"]["node"].position
	neighbors["nw"]["node"].start_move_to(neighbors["w"]["node"].position)
	neighbors["w"]["node"].start_move_to(neighbors["sw"]["node"].position)
	neighbors["sw"]["node"].start_move_to(neighbors["se"]["node"].position)
	neighbors["se"]["node"].start_move_to(neighbors["e"]["node"].position)
	neighbors["e"]["node"].start_move_to(neighbors["ne"]["node"].position)
	neighbors["ne"]["node"].start_move_to(nw_pos)

func _on_Gem_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed == true:
		rotate_neighbors()

func start_move_to(pos):
	position = pos
	
	
	
	