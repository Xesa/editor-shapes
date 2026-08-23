# EditorShapes

EditorShapes is a small plugin for Godot 4.X that allows you to define shapes directly in the editor for drawing or logic purposes.

The main advantage of this plugin is that every node in Godot that allows you to define a shape and edit it by dragging its handles is either a physics based node or a `Control` node that doesn't inherit from the `Node2D` hierarchy. This plugin adds that same functionality, with a `Node2D` based node that doesn't implement any physics behaviour.

> [!warning]
> This is a very early version of the plugin. Although it works well and has been tested, expect breaking changes in future updates.
> Any breaking changes will be listed in the changelog.

# Features

### Works like a built-in editable shape

The plugin allows you to drag the shape from each corner and side. Holding **Alt** makes it extend in both directions. Holding **Ctrl/Command** keeps it square.

### Snap to grid, customizable for each node

Set the snap grid size for each node, or share the same configuration between multiple nodes by using a shared resource.

### Customize editor colors and make the shape visible at runtime

You can set custom colors for the shape's outline and handles in the editor. You can also make the shape visible at runtime, giving it a similar visual role to a `ColorRect` while keeping it within the `Node2D` hierarchy.

### Create masks

Add a mask that makes the shape invisible within a defined area. A mask node doesn't necessarily need to be a child of the masked node; it can be placed anywhere in the scene tree.

# How to use

The plugin is straightforward to use. To define a shape, simply add a `RectangleZone2D` node to your scene.

### Customization

- Add a resource to the `Zone Configuration` property. If no resource is assigned, the node will use a default configuration.
- To make the shape visible at runtime, set the `Visible on Runtime` property to `true`. You can also change the `Color` property.
- If you set `Always Visible` to `true`, the shape's outline will always be visible in the editor, even when neither the node nor one of its direct parents is selected.
- You can tweak the remaining properties to configure snapping and editor visibility.

### Masking

- Add a `RectangleMaskZone2D` node to your scene.
- If you make it a direct child of a `RectangleZone2D` node, it will mask that node.
- Alternatively, you can add one or more `RectangleZone2D` nodes to the `Masked Zones` array to mask those shapes.

# FAQ

#### Can I undo / redo my changes?

Yes. The plugin uses Godot's undo/redo system, so any changes you make to a shape will be properly registered.

#### Will you expand this plugin to support other shapes?

Yes. I plan to add support for circle shapes. For polygon shapes, I might find a way to add masking support using the existing `Polygon2D` node.

#### I added a mask, but it's not visible in the editor

Unfortunately, dynamically adding masks is still a feature I want to implement, but haven't had time to. The same applies to adding or modifying masks at runtime.