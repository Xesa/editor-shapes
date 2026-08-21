## A rectangular colored zone defined by a [RectangleShape2D].
##
## The shape of this node will be visible during runtime. If you want to use
## a shape only to define boundaries in the editor, use [RectangleZone2D] instead.[br]
##
## This node provides custom editor visualization and handles for resizing the zone.
## Supports per-zone snapping and configurable editor visibility.
@tool
@icon("../icons/rectangle_color_zone_2d.svg")
class_name RectangleColorZone2D extends RectangleZone2D


## The color and opacity of the resulting shape that will be visible during runtime.
## This property can be edited during runtime and it will affect the visible polygon.
@export var shape_color : Color = Color.WHITE:
	set(value): shape_color = value; _set_polygon_color(value)


var polygon : Polygon2D


func _enter_tree():
	if !Engine.is_editor_hint():
		_render_polygon()
	

func _render_polygon():
	
	polygon = Polygon2D.new()
	polygon.color = shape_color

	polygon.polygon = [
		Vector2(-1, -1) * shape.size / 2,
		Vector2(1, -1) * shape.size / 2,
		Vector2(1, 1) * shape.size / 2,
		Vector2(-1, 1) * shape.size / 2
	]
	
	add_child(polygon)


func _set_polygon_color(color : Color) -> void:
	if polygon:
		polygon.color = color
