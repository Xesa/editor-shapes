## A rectangular zone that allows masking other [code]RectangleZone2D[/code] nodes.
##
## If the [member masked_zones] property is empty, this node will mask only
## its direct parent, as long as it is a [RectangleZone2D] node.[br][br]
##
## If one or more [RectangleZone2D] nodes are set in the [member masked_zones] property,
## the shape of this node will mask them, instead of its direct parent.[br][br]
##
## In any case, if this node is not placed inside the shape limits of any of those nodes,
## this node will have no effect.[br][br]
##
## During the [code]_ready()[/code] function, this node will register itself
## to each of the zones set in the [code]masked_zones[/code] nodes and then
## it will free itself from the scene.[br][br]
##
## Editor color, handle size, grid snapping and other configurations can also
## be set with a custom resource. If no resource is provided, the default settings will be applied.
@tool
@icon("../icons/rectangle_masking_zone_2d.svg")
class_name RectangleMaskingZone2D extends RectangleZone2D

const DEFAULT_MASK_COLOR := Color(0.8, 0.4, 0.8, 1.0)


## Array of [RectangleZone2D] nodes that will be masked by this zone.
@export var masked_zones : Array[RectangleZone2D] = []


func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	if masked_zones.size() == 0:
		var parent := get_parent()
		
		if parent is RectangleZone2D:
			parent.add_mask(self)
	
	else:
		for zone in masked_zones:
			zone.add_mask(self)
	
	queue_free()


# region Getter Methods

func get_color() -> Color:
	return Color.TRANSPARENT
	
func is_visible_on_runtime() -> bool:
	return false
	
func get_editor_color() -> Color:
	return zone_configuration.editor_color if zone_configuration else DEFAULT_MASK_COLOR
	
func replaces_editor_color() -> bool:
	return false
	
func get_fill_color() -> Color:
	var color := get_editor_color()
	var opacity := zone_configuration.fill_opacity if zone_configuration else 0.0
	color.a = opacity / 100.0
	return color
	
# endregion


# region Setter Methods

func add_mask(mask : RectangleMaskingZone2D) -> void:
	pass
	
# endregion


# region Draw Methods

func _draw() -> void:
	pass
	
# endregion
	
	

		

	
