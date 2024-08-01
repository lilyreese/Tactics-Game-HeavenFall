class_name Grid_Cell extends RefCounted

var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")

var cell_coordinate:Vector3i

var cell_distance_pathfinding:int
var parent_cell_pathfinding:Grid_Cell

var cell_ground_offset:Vector3

var grid_object_in_cell:Grid_Object

var game_board:Game_Board

func _init(coordinate:Vector3i, board:Game_Board) -> void:
	cell_coordinate = coordinate
	game_board = board

	_update_ground_offset()
	
	#print(cell_coordinate, cell_ground_offset)

func add_object_to_cell(object:Grid_Object) -> void:
	grid_object_in_cell = object

func remove_object_from_cell() -> void:
	grid_object_in_cell = null

func reset_cell_pathfinding() -> void:
	cell_distance_pathfinding = 0
	parent_cell_pathfinding = null
	
func _update_ground_offset() -> void:
	var space_state:PhysicsDirectSpaceState3D = game_board.get_world_3d().direct_space_state
	# use global coordinates, not local to node
	var from:Vector3 = grid_resource.to_world(cell_coordinate) + (Vector3.UP * 5)
	var to:Vector3 = grid_resource.to_world(cell_coordinate) + (Vector3.DOWN * 10)
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 256)
	var result:Dictionary = space_state.intersect_ray(query)
	
	if result:
		cell_ground_offset = Vector3(0,result['position'].y,0)
