@tool
class_name Cell_Selection_Overlay extends Terrain_Grid

func draw_overlay(cells:PackedVector3Array):
	clear()
	for cell:Vector3 in cells:
		var offset_cell:Vector3i = Vector3i(cell.x, cell.y+1, cell.z)
		set_cell_item(offset_cell, 0)
