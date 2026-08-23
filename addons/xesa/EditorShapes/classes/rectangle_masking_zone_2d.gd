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


## Array of [RectangleZone2D] nodes that will be masked by this zone.
@export var masked_zones : Array[RectangleZone2D] = []


func _ready() -> void:
	
	if masked_zones.size() == 0:
		var parent := get_parent()
		
		if parent is RectangleZone2D:
			parent.add_mask(self)
	
	else:
		for zone in masked_zones:
			zone.add_mask(self)
	
	if !Engine.is_editor_hint():
		queue_free()


func _draw() -> void:
	
	if Engine.is_editor_hint():
		draw_rect(Rect2(-size / 2.0, size), get_color())
		
		
func add_mask(mask : RectangleMaskingZone2D) -> void:
	pass
