extends Area2D

export var color = 0 #setget set_color, get_color
export var clickable = true
export var on_edge = false
onready var target_pos = position
onready var game = get_node("/root/Game")
var move_dir_sec = 0.25
var move_dir_progress = 0.0
var neighbors = {}
var move_queue = []
var wait_time = 0.0
var max_queue_size = 1
var correct_spot = false
export var initialized = false
onready var move_sfx = game.get_node("Audio/GemMoveSFX")
onready var cant_move_sfx = game.get_node("Audio/CantMoveSFX")
onready var prev_pos = position
# Called when the node enters the scene tree for the first time.
func _ready():
	var slots = get_tree().get_nodes_in_group("slots")
	for slot in slots:
		if position == slot.position:
			set_color(slot.get_color())

func set_color(col):
	$Sprite.frame = col
	color = col

func time_until_ready():
	if is_idle():
		return 0
	
	return len(move_queue) * move_dir_sec + move_dir_sec - move_dir_progress

func clear_queue():
	move_queue = []
func is_idle():
	if target_pos == position and len(move_queue) == 0 and move_dir_progress == 0:
		return true
	return false

func set_wait_time(delay):
	wait_time = delay - (time_until_ready())
		
func get_color():
	return color
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_idle():
		z_index = 0
	else:
		z_index = 15
	
	if wait_time > 0 and position == target_pos:
		wait_time -= delta
		return
	
	if wait_time < 0:
		wait_time = 0
	if target_pos == position and len(move_queue) != 0:
		target_pos = move_queue.pop_front()
		move_dir_progress = 0.0
		move_sfx.play()
	if target_pos != position:
		move_dir_progress += delta
		var progress_frac = move_dir_progress / move_dir_sec
		if move_dir_progress >= move_dir_sec:
			position = target_pos
			prev_pos = position
			move_dir_progress = 0
		else:
			var x_delta = target_pos.x - prev_pos.x
			var y_delta = target_pos.y - prev_pos.y
			position.x = prev_pos.x + x_delta * progress_frac
			position.y = prev_pos.y + y_delta * progress_frac
	elif move_dir_progress != 0.0:
		move_dir_progress = 0.0

func final_target_pos():
	if len(move_queue) > 0:
		return move_queue.back()
	return target_pos
	
func determine_neighbors():
	neighbors = {
		"ne": {
			"x": final_target_pos().x - 32,
			"y": final_target_pos().y - 56,
			"node": null
		},
		"e": {
			"x": final_target_pos().x - 64,
			"y": final_target_pos().y,
			"node": null
		},
		"se": {
			"x": final_target_pos().x - 32,
			"y": final_target_pos().y + 56,
			"node": null
		},
		"sw": {
			"x": final_target_pos().x + 32,
			"y": final_target_pos().y + 56,
			"node": null
		},
		"nw": {
			"x": final_target_pos().x + 32,
			"y": final_target_pos().y - 56,
			"node": null
		},
		"w": {
			"x": final_target_pos().x + 64,
			"y": final_target_pos().y,
			"node": null
		}
	}
	clickable = true
	on_edge = false
	var gems = get_tree().get_nodes_in_group("gems")
	for gem in gems:
		for neighbor in neighbors.values():
			if gem.final_target_pos().x == neighbor["x"] \
			and gem.final_target_pos().y == neighbor["y"]:
				neighbor["node"] = gem
	for neighbor in neighbors.values():
		if neighbor["node"] == null:
			clickable = false
			on_edge = true
			return
		if len(neighbor["node"].move_queue) >= max_queue_size:
			clickable = false
			return


func rotate_neighbors(immediate=false):
	determine_neighbors()
	if not clickable or len(move_queue) > 0:
		if on_edge and not immediate:
			if not cant_move_sfx.playing:
				cant_move_sfx.play()
		return
	var max_wait_time = 0
	for neighbor in neighbors.values():
		var node = neighbor["node"]
		max_wait_time = max(max_wait_time, node.time_until_ready())
		
	for neighbor in neighbors.values():
		var node = neighbor["node"]
		node.set_wait_time(max_wait_time)
	
	var nw_pos = neighbors["nw"]["node"].final_target_pos()
	
	neighbors["nw"]["node"].start_move_to(neighbors["w"]["node"].final_target_pos(), immediate)
	neighbors["w"]["node"].start_move_to(neighbors["sw"]["node"].final_target_pos(), immediate)
	neighbors["sw"]["node"].start_move_to(neighbors["se"]["node"].final_target_pos(), immediate)
	neighbors["se"]["node"].start_move_to(neighbors["e"]["node"].final_target_pos(), immediate)
	neighbors["e"]["node"].start_move_to(neighbors["ne"]["node"].final_target_pos(), immediate)
	neighbors["ne"]["node"].start_move_to(nw_pos, immediate)
	
func _on_Gem_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed == true:
		if not is_idle():
			return
		if game.mouse_locked:
			return
		rotate_neighbors()

func start_move_to(pos, immediate=false):
	if immediate:
		position = pos
		target_pos = pos
		prev_pos = pos
		move_dir_progress = 0
	else:
		move_queue.push_back(pos)
	

func is_correct():
	return correct_spot

func _on_Gem_area_entered(area):
	if area.is_in_group("slots"):
		if area.get_color() == get_color():
			$Sprite.modulate = Color(1,1,1, 1)
			correct_spot = true
			if initialized:
				game.check_win()
		else:
			$Sprite.modulate = Color(0.5, 0.5, 0.5, 1)
			correct_spot = false
	pass # Replace with function body.
