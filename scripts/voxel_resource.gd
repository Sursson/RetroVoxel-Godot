# VOXEL RESOURCE v1.0
# Stores Voxel Object properties
# Created by László Savanya - 2026

# Feel free to use in your personal or commercial project
# Credits mention is not mandantory, but much appreciated! :) 

extends Resource
class_name VoxelResource

enum DrawDirection {
	X_Positive, ##Sprite is drawn from the [b]X axis[/b]. Each sprite will be drawn [b]on top[/b] of the last one.
	X_Negative, ##Sprite is drawn from the [b]X axis[/b]. Each sprite will be drawn [b]under[/b] the last one.
	Y_Positive,	##Sprite is drawn from the [b]Y axis[/b]. Each sprite will be drawn [b]on top[/b] of the last one.
	Y_Negative,	##Sprite is drawn from the [b]Y axis[/b]. Each sprite will be drawn [b]under[/b] the last one.
	Z_Positive,	##Sprite is drawn from the [b]Z axis[/b]. Each sprite will be drawn [b]on top[/b] of the last one.
	Z_Negative,	##Sprite is drawn from the [b]Z axis[/b]. Each sprite will be drawn [b]under[/b] the last one.
	}
enum RowOrder {
	Top_to_Bottom, ##To to bottom
	Bottom_to_Top, ##Bottom to top
}

## Voxel texture atlas.
@export var voxelAtlas : Image
## Number of frames on each axis
@export var slice_sheet : Vector2i = Vector2i.ONE

## Rows' order
@export var rowOrder : RowOrder
## Direction in along which axis the slice sheets are drawn
@export var draw_direction : DrawDirection

@export_group("Mirror")
@export var mirror_x : bool
@export var mirror_y : bool
@export var mirror_z : bool

@export_group("")
@export var pivotOffset : Vector3
