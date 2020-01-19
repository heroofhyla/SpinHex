extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scrambles = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("=====\nshuffling...")
	randomize()
	var gems = get_tree().get_nodes_in_group("gems")
	for i in range(0,scrambles):
		var random_gem = int(randf() * (len(gems) - 1) + .5)
		var gem = gems[random_gem]
		gem.rotate_neighbors(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
