## A rectangular zone defined by a [RectangleShape2D].
##
## The shape of this node is only visible in the editor. If you want to
## create a visible shape during runtime, use [RectangleColorZone2D] instead.[br]
##
## This node provides custom editor visualization and handles for resizing the zone.
## Supports per-zone snapping and configurable editor visibility.
@tool
@icon("../icons/rectangle_zone_2d.svg")
class_name RectangleZone2D extends Node2D


@export_group("Shape")

## The rectangle shape used by this zone.
@export var shape: RectangleShape2D

## Enables snapping when resizing the zone in the editor.
@export var snap := true

## The size of each snapping step when resizing the zone.
@export var snap_size := Vector2(16.0, 16.0):
	set(value):
		snap_size = value.max(Vector2.ZERO)


@export_group("Visibility")

## Keeps the rectangle visible in the editor even when this node is not selected.
## Note: at least one [code]RectangleZone2D[/code] node has to be selected.
@export var always_visible := true

## The width of the rectangle outline in pixels.
@export_range(1, 10, 1, "prefer_slider", "suffix:px")
var line_size: int = 2

## The size of the resize handles in pixels.
@export_range(2, 20, 1, "prefer_slider", "suffix:px")
var handle_size: int = 8

## The color and opacity of the rectangle outline. This only affects the editor.
@export var line_color := Color(0.35, 1.0, 0.35, 0.25)

## The color and opacity used to fill the rectangle. This only affects the editor.
@export var fill_color := Color(0.35, 1.0, 0.35, 0.0)

## The color of the resize handles. This only affects the editor.
@export var handle_color := Color(0.35, 1.0, 0.35, 1.0)
