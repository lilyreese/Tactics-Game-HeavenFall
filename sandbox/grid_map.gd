extends GridMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0,500000):
		set_cell_item(Vector3(i,0,0), 0)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
