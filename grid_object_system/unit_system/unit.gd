@tool
class_name Unit extends Grid_Object

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow_3d: PathFollow3D = $PathFollow3D

@export var movement_speed:float = 1
@export var movement_range:int = 3

var _cells_moved_this_turn:int = 0:
	set = _set_cells_moved_this_turn
var movement_left:int = movement_range

@export var selected:bool = false:
	set = _set_selected

	
var movement_array:Array[Vector3] = []
var is_moving:bool = false
	
func move_along_path(cells_path:Array[Vector3]) -> void:
	movement_array = cells_path
	
	if movement_array.is_empty():
		return
	
	is_moving = true
	_reset_movement_path()
	
	current_cell = movement_array[-1]
	_cells_moved_this_turn += (movement_array.size() - 1)
	
	for cell:Vector3 in cells_path:
		curve.add_point(to_local(grid_resource.to_world(cell)))
	
	_tween_movement()

func _tween_movement() -> void:
	if movement_array.is_empty():
		_finish_movement()
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	tween.tween_property(path_follow_3d, "progress_ratio", 1, movement_speed)
	
	tween.tween_callback(_finish_movement)

func _finish_movement() -> void:
	_reset_movement_path()
	is_moving = false

func _set_selected(value:bool) -> void:
	selected = value
	if selected:
		animation_player.play("selected")
	else:
		animation_player.play("idle")
		
func _reset_movement_path() -> void:
	path_follow_3d.position = Vector3.ZERO
	path_follow_3d.progress = 0
	global_position = grid_resource.to_world(current_cell)	
	curve.clear_points()
	
	
func _set_cells_moved_this_turn(value:int) -> void:
	_cells_moved_this_turn = value
	movement_left = movement_range - _cells_moved_this_turn
	
	if movement_left < 0:
		movement_left = 0

func restart_turn() -> void:
	_cells_moved_this_turn = 0
