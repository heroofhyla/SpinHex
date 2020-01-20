extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scrambles = 1000
var mouse_locked = false
onready var gems = get_tree().get_nodes_in_group("gems")
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(0,scrambles):
		var random_gem = int(randf() * (len(gems) - 1) + .5)
		var gem = gems[random_gem]
		gem.rotate_neighbors(true)
	
	for gem in gems:
		gem.initialized = true

func check_win():
	for gem in gems:
		if not gem.is_correct():
			return false
		
	mouse_locked = true
	$WinMessage.visible = true
	for gem in gems:
		gem.clear_queue()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
