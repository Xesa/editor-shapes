class_name RectangleZone2DResource extends Resource


## If set to true, this shape will be visible on runtime,
## showing the color set in the [member color] property.
@export var visible_on_runtime := false

## The color and opacity used to fill the rectangle during runtime.
## This will only be visible if [member visible_on_runtime] is set to true.
@export var color := Color.WHITE


@export_group("Snapping")

## Enables snapping when resizing the zone in the editor.
@export var snap := true

## The size of each snapping step when resizing the zone.
@export var snap_size := Vector2(16.0, 16.0):
	set(value):
		snap_size = value.max(Vector2.ZERO)


@export_group("Editor")

## Keeps the rectangle visible in the editor even when this node
## or a direct parent is not selected.
@export var always_visible := false

## If set to true, the fill color and opacity used in the editor will be the same
## as the one set in the [member color] property.
@export var replace_fill_color := false

## The color used for the outline, handles and fill color used in the editor.
@export var editor_color := RectangleZone2D.DEFAULT_EDITOR_COLOR

## The width of the rectangle outline in pixels.
@export_range(1, 4, 1, "prefer_slider", "suffix:px")
var line_size : int = 1.0

## The size of the resize handles in pixels.
@export_range(4, 16, 1, "prefer_slider", "suffix:px")
var handle_size : int = 8.0

## The opacity of the fill color. If [member replace_fill_color]
## is set to true, this will have no effect.
@export_range(0.0, 100.0, 1.0) var fill_opacity : float = 0.0
