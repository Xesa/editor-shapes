## A rectangular zone that can be used for drawing shapes or
## defining logical areas that are not tied to the physics system.
##
## The shape of this node is only visible in the editor by default.
## If you want to make this shape visible during runtime, add a resource
## to the [member zone_configuration] property and set the
## [member RectangleZone2DResource.visible_on_runtime] property from the resource to true.[br][br]
##
## Editor color, handle size, grid snapping and other configurations can also
## be set with a custom resource. If no resource is provided, the default settings will be applied.
@tool
@icon("../icons/rectangle_zone_2d.svg")
class_name RectangleZone2D extends Node2D

const DEFAULT_EDITOR_COLOR := Color(0.35, 1.0, 0.35, 1.0)

## The size of the shape.
@export var size := Vector2(16.0, 16.0)

## Use a resource to customize this zone's settings. If you don't
## use a resource, the default settings will be applied.
@export var zone_configuration : RectangleZone2DResource


var masking_zones : Array[RectangleMaskingZone2D] = []
var geometry: Array[Rect2] = []


# region Getter Methods

func get_color() -> Color:
	return zone_configuration.color if zone_configuration else Color.WHITE

func is_snap_enabled() -> bool:
	return zone_configuration.snap if zone_configuration else true

func get_snap_size() -> Vector2:
	return zone_configuration.snap_size if zone_configuration else Vector2(16.0, 16.0)

func is_visible_on_runtime() -> bool:
	return zone_configuration.visible_on_runtime if zone_configuration else false

func replaces_editor_color() -> bool:
	if is_visible_on_runtime():
		return true
	return zone_configuration.replace_fill_color if zone_configuration else false

func is_always_visible() -> bool:
	return zone_configuration.always_visible if zone_configuration else false

func get_line_size() -> float:
	return zone_configuration.line_size if zone_configuration else 1.0

func get_handle_size() -> float:
	return zone_configuration.handle_size if zone_configuration else 8.0
	
func get_editor_color() -> Color:
	return zone_configuration.editor_color if zone_configuration else DEFAULT_EDITOR_COLOR

func get_fill_color() -> Color:
	
	if replaces_editor_color():
		return get_color()
		
	var color := get_editor_color()
	var opacity := zone_configuration.fill_opacity if zone_configuration else 0.0
	color.a = opacity / 100.0
	return color
		
func get_global_rect() -> Rect2:
	return Rect2(global_position - (size / 2.0), size)
	
func get_local_rect() -> Rect2:
	return Rect2(-size / 2.0, size)
	
# endregion


# region Setter Methods

func add_mask(mask : RectangleMaskingZone2D) -> void:
	masking_zones.append(mask)
	_build_geometry()
	
# endregion


# region Draw Methods


func _draw() -> void:
	
	if is_visible_on_runtime():
		
		if !Engine.is_editor_hint() or replaces_editor_color():
			
			if geometry.size() == 0:
				draw_rect(Rect2(-size / 2.0, size), get_color())
				
			else:
				for rect in geometry:
					draw_rect(rect, get_color())
					
					
func _build_geometry() -> void:
	var zone_rect := get_local_rect()
	geometry = [zone_rect]

	for mask in masking_zones:
		var next: Array[Rect2] = []
		var mask_position := to_local(mask.global_position)
		var mask_rect := Rect2(mask_position - mask.size / 2.0, mask.size)

		for rect in geometry:
			next.append_array(_subtract_rect(rect, mask_rect))

		geometry = next
			
			
func _subtract_rect(source: Rect2, cutout: Rect2) -> Array[Rect2]:
	var result: Array[Rect2] = []

	if not source.intersects(cutout):
		result.append(source)
		return result

	var intersection := source.intersection(cutout)

	if intersection.position.y > source.position.y:
		result.append(Rect2(
			source.position,
			Vector2(source.size.x, intersection.position.y - source.position.y)
		))

	if intersection.end.y < source.end.y:
		result.append(Rect2(
			Vector2(source.position.x, intersection.end.y),
			Vector2(source.size.x, source.end.y - intersection.end.y)
		))

	if intersection.position.x > source.position.x:
		result.append(Rect2(
			Vector2(source.position.x, intersection.position.y),
			Vector2(intersection.position.x - source.position.x, intersection.size.y)
		))

	if intersection.end.x < source.end.x:
		result.append(Rect2(
			Vector2(intersection.end.x, intersection.position.y),
			Vector2(source.end.x - intersection.end.x, intersection.size.y)
		))

	return result
	
# endregion
