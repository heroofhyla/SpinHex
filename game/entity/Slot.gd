extends Area2D
export var color = 0 #setget set_color, get_color
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func set_color(col):
	$Sprite.frame = col+4
	color = col
	
func get_color():
	return color
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_color(int(randf() * 2 + 0.5))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Slot_area_entered(area):
	if area.is_in_group("gems"):
		if area.get_color() == get_color():
			$Sprite.modulate = Color(1,1,1, 1)
		else:
			$Sprite.modulate = Color(0.5, 0.5, 0.5, 1)
	pass # Replace with function body.
