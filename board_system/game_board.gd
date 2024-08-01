class_name Game_Board extends Node3D

@onready var units: Node = $Units
@onready var cell_selection_overlay: Cell_Selection_Overlay = $Overlays/CellSelectionOverlay
@onready var cursor: Cursor = $Player/Cursor

@export var grid_resource:Grid_Resource = preload("res://grid_system/grid_resource.tres")
@export var terrain_grid:Terrain_Grid

var terrain_array:PackedVector3Array
var units_dictionary:Dictionary = {} # {(Cell Coordinate):Unit}

var selected_unit:Unit

#Temporary
var cell_parenthood:Dictionary = {}
var cells_in_range:PackedVector3Array = []

func _ready() -> void:
	_update_terrain_array()	
	_update_units_dictionary()
	
	cursor.cursor_interacted.connect(_on_cursor_interacted)
	cursor.cursor_moved.connect(_on_cursor_moved)

func _on_cursor_interacted(at_cell:Vector3i) -> void:
	_update_units_dictionary()
	
	if terrain_array.has(at_cell):
		_select_cell_at(at_cell)
	else:
		if selected_unit:
			selected_unit.selected = !selected_unit.selected
			selected_unit = null
			cell_selection_overlay.clear()
	pass
	
func _on_cursor_moved(to_cell:Vector3i) -> void:
	pass
			
func _select_cell_at(at_cell:Vector3i) -> void:
	if units_dictionary.has(at_cell):
		if units_dictionary[at_cell].is_moving:
			return
		units_dictionary[at_cell].selected = !units_dictionary[at_cell].selected
		selected_unit = units_dictionary[at_cell]
		
		cells_in_range = _get_cells_in_range(at_cell, selected_unit.movement_left)
		cell_selection_overlay.draw_overlay(cells_in_range)
		
	elif cells_in_range.has(at_cell) and selected_unit: 
		selected_unit.move_along_path(_get_path_towards_target(selected_unit.current_cell, at_cell))
		selected_unit.selected = !selected_unit.selected
		selected_unit = null
		cell_selection_overlay.clear()
		
	else:
		cell_selection_overlay.clear()
		if selected_unit:
			selected_unit.selected = !selected_unit.selected
			selected_unit = null
	
func _update_terrain_array() -> void:
	if terrain_grid:
		terrain_array = terrain_grid.get_used_cells()	
		
func _update_units_dictionary() -> void:
	units_dictionary.clear()
	for child in units.get_children():
		if child is not Unit:
			push_warning("Not Unit node in Units hierarchy, queueing it free. ", child.name)
			child.queue_free()
			continue
		
		var unit:Unit = child as Unit
		
		units_dictionary[unit.current_cell] = unit

func _get_cells_in_range(start_cell:Vector3i, max_range:int, include_starting_cell:bool = true) -> PackedVector3Array:
	const DIRECTIONS = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
	
	var out:PackedVector3Array
	
	var stack:Array[Vector3i] = [start_cell]
	var cell_distance_dictionary:Dictionary = {start_cell:0} #(Cell Coordinate:Distance)
	
	#temporary
	#cell_parenthood.clear()
	
	while !stack.is_empty():
		var current_cell:Vector3i = stack.pop_front()
		
		if out.has(current_cell):
			continue
		
		if not terrain_array.has(current_cell):
			continue
		
		if cell_distance_dictionary[current_cell] > max_range:
			continue
			
		if _is_cell_occupied(current_cell):
			continue
		
		out.append(current_cell)
		
		for direction in DIRECTIONS:
			var neighbor:Vector3i = current_cell + direction
			
			if out.has(neighbor):
				continue
		
			if not terrain_array.has(neighbor):
				continue
				
			if _is_cell_occupied(neighbor):
				continue

			cell_distance_dictionary[neighbor] = cell_distance_dictionary[current_cell] + 1
			
			if cell_distance_dictionary[neighbor] > max_range:
				continue
				
			#temporary
			cell_parenthood[neighbor] = current_cell
			stack.append(neighbor)	

	if !include_starting_cell:
		if out.has(start_cell):
			out.remove_at(out.find(start_cell))
	return out

func _get_path_towards_target(start_cell:Vector3i, target_cell:Vector3i) -> PackedVector3Array:
	const DIRECTIONS = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
	
	var out:PackedVector3Array
	var current_tile = target_cell
	
	while current_tile != start_cell:
		out.append(current_tile)
		if cell_parenthood.has(current_tile):
			current_tile = cell_parenthood[current_tile]
		else:
			break
			
	out.append(start_cell)
	out.reverse()
	return out
	
func _is_cell_occupied(cell_coordinate:Vector3i) -> bool:
	if units_dictionary.has(cell_coordinate):
		if units_dictionary[cell_coordinate] != selected_unit:
			return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("restart_turn"):
		for unit:Unit in units_dictionary.values():
			unit.restart_turn()
