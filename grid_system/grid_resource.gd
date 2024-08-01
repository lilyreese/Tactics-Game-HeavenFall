@tool
class_name Grid_Resource extends Resource

signal cell_size_changed()

@export var cell_size:int = 1:
	set = _set_cell_size

var cell_size_3d:Vector3 = Vector3(cell_size, cell_size, cell_size)
var _half_cell:Vector3 = cell_size_3d / 2

func to_world(grid_coordinate:Vector3) -> Vector3:
	var world_position:Vector3 = (grid_coordinate * cell_size_3d) + _half_cell
	return world_position
	
func to_grid(world_position:Vector3) -> Vector3:
	var grid_coordinate:Vector3 = (world_position / cell_size_3d).floor()
	
	return grid_coordinate

func _set_cell_size(value:int) -> void:
	cell_size = value
	cell_size_3d = Vector3(cell_size, cell_size, cell_size)
	_half_cell = cell_size_3d / 2	
	cell_size_changed.emit()
