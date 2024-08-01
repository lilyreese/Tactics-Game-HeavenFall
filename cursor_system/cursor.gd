class_name Cursor extends Node3D
const RAY_LENGTH = 1000

signal cursor_moved(to)
signal cursor_interacted(at_cell)

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")
@export var current_cell:Vector3

var _over_valid_cell:bool = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
		
	if event is InputEventMouseMotion:
		_cast_ray_to_ground()
		
	if event.is_action_released("cursor_interact"):
		if _over_valid_cell:
			cursor_interacted.emit(current_cell)
		else:
			cursor_interacted.emit(Vector3.INF)
	

func _cast_ray_to_ground() -> void:
	var space_state:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var cam:Camera3D = get_viewport().get_camera_3d()
	var mousepos:Vector2 = get_viewport().get_mouse_position()

	var origin:Vector3 = cam.project_ray_origin(mousepos)
	var end:Vector3 = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 256)
	
	query.collide_with_areas = true

	var result:Dictionary = space_state.intersect_ray(query)
	
	if !result:
		_over_valid_cell = false
		mesh_instance_3d.hide()
		return
	
	if result['position'].y < 0:
		_over_valid_cell = false
		mesh_instance_3d.hide()
		return	
	
	mesh_instance_3d.show()
	_over_valid_cell = true
	current_cell = grid_resource.to_grid(Vector3(result['position'].x, 0, result['position'].z))
	global_position = grid_resource.to_world_offset(current_cell)
	
	if grid_resource.grid_cells.has(current_cell):
		print(grid_resource.grid_cells[current_cell].cell_ground_offset)
	
	cursor_moved.emit(current_cell)
