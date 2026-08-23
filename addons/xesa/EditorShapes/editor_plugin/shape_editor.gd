@tool
extends EditorPlugin

# region Selected Node Info

var selected_parent : Node2D
var selected: RectangleZone2D

# endregion


# region Drag Info

var dragging := false
var drag_handle := -1

var drag_start_mouse := Vector2.ZERO
var drag_start_local_mouse := Vector2.ZERO
var drag_start_size := Vector2.ZERO
var drag_start_position := Vector2.ZERO
var drag_start_transform := Transform2D.IDENTITY
var drag_snapped_size := Vector2.ZERO

# endregion


# region Editor Methods

func _handles(object : Object) -> bool:
	
	if object is RectangleZone2D:
		return true
	
	if object is Node2D:
		return _scan_children(object)
			
	return false
	
	
func _scan_children(object : Object) -> bool:
	
	for child in object.get_children():
		if child is RectangleZone2D:
			return true
			
		if _scan_children(child) == true:
			return true
			
	return false


func _edit(object : Object) -> void:
	
	if object is RectangleZone2D:
		selected = object as RectangleZone2D
		selected_parent = null
		
	elif object is Node2D:
		selected = null
		selected_parent = object

	dragging = false
	drag_handle = -1
	
	drag_start_mouse = Vector2.ZERO
	drag_start_local_mouse = Vector2.ZERO
	drag_start_size = Vector2.ZERO
	drag_start_position = Vector2.ZERO
	drag_start_transform = Transform2D.IDENTITY
	drag_snapped_size = Vector2.ZERO

	update_overlays()
	
# endregion


# region Canvas Methods

func _forward_canvas_draw_over_viewport(overlay : Control) -> void:

	var root := get_editor_interface().get_edited_scene_root()
	
	if root == null:
		return

	for node in root.find_children("*", "RectangleZone2D", true, false):
		if node.is_always_visible():
			_draw_rectangle(overlay, node)
		
	if selected_parent:
		for node in selected_parent.find_children("*", "RectangleZone2D", true, false):
			if !node.is_always_visible():
				_draw_rectangle(overlay, node)

	if selected:
		
		for node in selected.find_children("*", "RectangleZone2D", true, false):
			if !node.is_always_visible():
				_draw_rectangle(overlay, node)
				
		if !selected.is_always_visible():
			_draw_rectangle(overlay, selected)
			
		_draw_handles(overlay, selected)
		
		
func _draw_rectangle(overlay : Control, zone : RectangleZone2D) -> void:
	

	var transform := EditorInterface.get_editor_viewport_2d().get_final_transform()
	var size := zone.size

	var local_points := PackedVector2Array([
		Vector2(-size.x, -size.y) / 2.0,
		Vector2( size.x, -size.y) / 2.0,
		Vector2( size.x,  size.y) / 2.0,
		Vector2(-size.x,  size.y) / 2.0,
	])

	var points := PackedVector2Array()

	for point in local_points:
		points.append(transform * zone.to_global(point))

	if !(zone.is_visible_on_runtime() and zone.replaces_editor_color()):
		
		var fill_color := zone.get_fill_color()
		
		if fill_color.a > 0.0:
			overlay.draw_colored_polygon(points, fill_color)

	overlay.draw_polyline(points, zone.get_editor_color(), zone.get_line_size())
	overlay.draw_line(points[3], points[0], zone.get_editor_color(), zone.get_line_size())
	
	
func _draw_handles(overlay : Control, zone : RectangleZone2D) -> void:
	
	var handles := _get_handle_positions()

	for point in handles:
		overlay.draw_rect(
			Rect2(point - Vector2(4, 4), zone.get_handle_size() * Vector2.ONE),
			zone.get_editor_color()
		)
		
# endregion


# region Input Methods

func _forward_canvas_gui_input(event : InputEvent) -> bool:
	if selected == null:
		return false

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return false

		if event.pressed:
			var handles := _get_handle_positions()

			for i in handles.size():
				if handles[i].distance_to(event.position) <= 8.0:
					dragging = true
					drag_handle = i
					drag_start_mouse = event.position
					drag_start_size = selected.size
					drag_start_position = selected.position
					drag_start_transform = selected.global_transform

					var transform := EditorInterface.get_editor_viewport_2d().get_final_transform()
					var inverse := transform.affine_inverse()
					var global_mouse : Vector2 = inverse * event.position

					drag_start_local_mouse = selected.to_local(global_mouse)
					drag_snapped_size = _snap_size_to_grid(drag_start_size)

					return true

		else:
			
			if dragging:
				_manage_undo_redo()
				dragging = false
				drag_handle = -1
				return true

	if event is InputEventMouseMotion and dragging:
		_resize_from_handle(event.position, event.alt_pressed, event.ctrl_pressed)
		update_overlays()
		return true

	return false
	
# endregion


# region Undo / Redo

func _manage_undo_redo() -> void:

				var undo_redo := get_undo_redo()

				undo_redo.create_action("Resize RectangleZone2D")

				undo_redo.add_do_property(
					selected,
					"size",
					selected.size
				)

				undo_redo.add_do_property(
					selected,
					"position",
					selected.position
				)

				undo_redo.add_undo_property(
					selected,
					"size",
					drag_start_size
				)

				undo_redo.add_undo_property(
					selected,
					"position",
					drag_start_position
				)

				undo_redo.commit_action()
				
# endregion
		
		
# region Snapping Methods

func _snap_point(point : Vector2) -> Vector2:
	
	var snap_size := selected.get_snap_size()

	if not is_zero_approx(snap_size.x):
		point.x = round(point.x / snap_size.x) * snap_size.x

	if not is_zero_approx(snap_size.y):
		point.y = round(point.y / snap_size.y) * snap_size.y

	return point
	
	
func _snap_size(size : Vector2) -> Vector2:
	var result := drag_snapped_size
	var snap_size := selected.get_snap_size()

	if not is_zero_approx(snap_size.x):
		result.x = _snap_axis(
			size.x,
			drag_snapped_size.x,
			snap_size.x
		)

	if not is_zero_approx(snap_size.y):
		result.y = _snap_axis(
			size.y,
			drag_snapped_size.y,
			snap_size.y
		)

	return result
	
	
func _snap_axis(
	value : float,
	current : float,
	step : float
) -> float:
	var hysteresis := step * 0.25

	var upper_threshold := current + step * 0.5 + hysteresis
	var lower_threshold := current - step * 0.5 - hysteresis

	if value > upper_threshold:
		return current + step

	if value < lower_threshold:
		return max(current - step, step)

	return current
	
	
func _snap_size_to_grid(size : Vector2) -> Vector2:
	var result := size
	var snap_size := selected.get_snap_size()

	if not is_zero_approx(snap_size.x):
		result.x = round(size.x / snap_size.x) * snap_size.x

	if not is_zero_approx(snap_size.y):
		result.y = round(size.y / snap_size.y) * snap_size.y

	return result

# endregion


# region Resizing Methods

func _get_handle_positions() -> PackedVector2Array:
	var transform := EditorInterface.get_editor_viewport_2d().get_final_transform()
	var size := selected.size

	var local_points := PackedVector2Array([
		# Corners
		Vector2(-size.x, -size.y) / 2.0,
		Vector2( size.x, -size.y) / 2.0,
		Vector2( size.x,  size.y) / 2.0,
		Vector2(-size.x,  size.y) / 2.0,

		# Center of lines
		Vector2(0.0, -size.y / 2.0),
		Vector2(size.x / 2.0, 0.0),
		Vector2(0.0, size.y / 2.0),
		Vector2(-size.x / 2.0, 0.0),
	])

	var points := PackedVector2Array()

	for point in local_points:
		points.append(transform * selected.to_global(point))

	return points


func _resize_from_handle(
	mouse_position: Vector2,
	centered: bool,
	squared: bool
) -> void:

	var transform := EditorInterface.get_editor_viewport_2d().get_final_transform()
	var inverse := transform.affine_inverse()

	var global_mouse := inverse * mouse_position
	var local_mouse := drag_start_transform.affine_inverse() * global_mouse

	var mouse_delta := local_mouse - drag_start_local_mouse
	var half := drag_start_size / 2.0

	var start_handle := Vector2.ZERO
	var fixed_point := Vector2.ZERO

	match drag_handle:
		0:
			start_handle = Vector2(-half.x, -half.y)
			fixed_point = Vector2(half.x, half.y)

		1:
			start_handle = Vector2(half.x, -half.y)
			fixed_point = Vector2(-half.x, half.y)

		2:
			start_handle = Vector2(half.x, half.y)
			fixed_point = Vector2(-half.x, -half.y)

		3:
			start_handle = Vector2(-half.x, half.y)
			fixed_point = Vector2(half.x, -half.y)

		4:
			start_handle = Vector2(0.0, -half.y)
			fixed_point = Vector2(0.0, half.y)

		5:
			start_handle = Vector2(half.x, 0.0)
			fixed_point = Vector2(-half.x, 0.0)

		6:
			start_handle = Vector2(0.0, half.y)
			fixed_point = Vector2(0.0, -half.y)

		7:
			start_handle = Vector2(-half.x, 0.0)
			fixed_point = Vector2(half.x, 0.0)

	var new_handle := start_handle + mouse_delta
	var new_size := drag_start_size

	if centered:
		match drag_handle:
			0, 1, 2, 3:
				new_size = new_handle.abs() * 2.0

			4, 6:
				new_size.y = abs(new_handle.y) * 2.0

			5, 7:
				new_size.x = abs(new_handle.x) * 2.0

	else:
		if drag_handle >= 4:
			match drag_handle:
				4, 6:
					new_size.y = abs(new_handle.y - fixed_point.y)

				5, 7:
					new_size.x = abs(new_handle.x - fixed_point.x)
		else:
			new_size = (new_handle - fixed_point).abs()

	# Squared
	if squared:
		var side := max(new_size.x, new_size.y)
		new_size = Vector2(side, side)

	# Snapped
	if selected.is_snap_enabled():
		new_size = _snap_size(new_size)
		drag_snapped_size = new_size
	else:
		drag_snapped_size = new_size

	new_size.x = max(new_size.x, 1.0)
	new_size.y = max(new_size.y, 1.0)

	# Centered
	if centered:
		selected.size = new_size
		selected.position = drag_start_position

	else:
		var new_center := Vector2.ZERO

		match drag_handle:
			0, 1, 2, 3:
				var direction := Vector2(
					sign(new_handle.x - fixed_point.x),
					sign(new_handle.y - fixed_point.y)
				)

				var snapped_handle := fixed_point + direction * new_size
				new_center = (fixed_point + snapped_handle) / 2.0

			4:
				new_center.y = (drag_start_size.y - new_size.y) / 2.0

			5:
				new_center.x = (new_size.x - drag_start_size.x) / 2.0

			6:
				new_center.y = (new_size.y - drag_start_size.y) / 2.0

			7:
				new_center.x = (drag_start_size.x - new_size.x) / 2.0

		selected.size = new_size
		selected.position = drag_start_position + new_center

	update_overlays()
	
# endregion
