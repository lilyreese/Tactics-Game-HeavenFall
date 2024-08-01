@tool
class_name Terrain_Grid extends GridMap

signal terrain_ready

@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")

func _init() -> void:
	grid_resource.cell_size_changed.connect(_on_grid_cell_size_changed)
		
func _ready() -> void:
	terrain_ready.emit()	
	
func _on_grid_cell_size_changed() -> void:
	cell_size = grid_resource.cell_size_3d
	cell_scale = grid_resource.cell_size
