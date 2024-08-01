@tool
class_name Grid_Object extends Path3D

@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")
@export var current_cell:Vector3i:
	set = _set_current_cell

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		curve = null
		
	else:
		curve = Curve3D.new()
		


func _set_current_cell(value:Vector3i) -> void:
	current_cell = value
	if Engine.is_editor_hint():
		align_position_to_grid()
	
func align_position_to_grid() -> void:
	position = grid_resource.to_world(current_cell)

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
		
	if position == Vector3.ZERO:
		return
	
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		current_cell = grid_resource.to_grid(position)
