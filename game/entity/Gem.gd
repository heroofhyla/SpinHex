tool
extends Area2D

export var color = 0 #setget set_color, get_color
export var clickable = true
onready var target_pos = position
onready var game = get_node("/root/Game")
var move_dir_sec = 0.5
var move_dir_progress = 0.0
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
func _process(delta):
	if target_pos != position:
		move_dir_progress += delta
		var progress_frac = move_dir_progress / move_dir_sec
		if move_dir_progress >= move_dir_sec:
			position = target_pos
			move_dir_progress = 0
		else:
			var x_delta = target_pos.x - position.x
			var y_delta = target_pos.y - position.y
			position.x += x_delta * progress_frac
			position.y += y_delta * progress_frac
	elif move_dir_progress != 0.0:
		move_dir_progress = 0.0
			
func determine_neighbors():
	neighbors = {
		"ne": {
			"x": target_pos.x - 32,
			"y": target_pos.y - 56,
			"node": null
		},
		"e": {
			"x": target_pos.x - 64,
			"y": target_pos.y,
			"node": null
		},
		"se": {
			"x": target_pos.x - 32,
			"y": target_pos.y + 56,
			"node": null
		},
		"sw": {
			"x": target_pos.x + 32,
			"y": target_pos.y + 56,
			"node": null
		},
		"nw": {
			"x": target_pos.x + 32,
			"y": target_pos.y - 56,
			"node": null
		},
		"w": {
			"x": target_pos.x + 64,
			"y": target_pos.y,
			"node": null
		}
	}
	clickable = true
	var gems = get_tree().get_nodes_in_group("gems")
	for gem in gems:
		for neighbor in neighbors.values():
			if gem.target_pos.x == neighbor["x"] \
			and gem.target_pos.y == neighbor["y"]:
				neighbor["node"] = gem
	for neighbor in neighbors.values():
		if neighbor["node"] == null:
			print_debug("found a null, can't move")
			clickable = false

func rotate_neighbors():
	determine_neighbors()
	if not clickable:
		return
		
	var nw_pos = neighbors["nw"]["node"].target_pos
	neighbors["nw"]["node"].start_move_to(neighbors["w"]["node"].target_pos)
	neighbors["w"]["node"].start_move_to(neighbors["sw"]["node"].target_pos)
	neighbors["sw"]["node"].start_move_to(neighbors["se"]["node"].target_pos)
	neighbors["se"]["node"].start_move_to(neighbors["e"]["node"].target_pos)
	neighbors["e"]["node"].start_move_to(neighbors["ne"]["node"].target_pos)
	neighbors["ne"]["node"].start_move_to(nw_pos)

func _on_Gem_input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed == true:
		rotate_neighbors()

func start_move_to(pos):
	target_pos = pos
	move_dir_progress = 0
	
	