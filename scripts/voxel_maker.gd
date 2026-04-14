# VOXEL MAKER v1.0
# Makes Particle System Voxels from Voxel Resource Objects
# Created by László Savanya - 2026

# Feel free to use in your personal or commercial project
# Credits mention is not mandantory, but much appreciated! :) 

@tool
extends GPUParticles3D

var voxelResolution : Vector3i

@export var voxelResource : VoxelResource
## Controls the size of each individual voxel
@export var voxelSize : float = 1
## Controls the scale of the whole object
## [br][i]Note: It just sets the Transform3D scale value universally on all axis[/i]
@export var voxelScale : float = 1

## Adds extra padding around the particle system's visibility AABB
## [br][i]Note: Measured in voxels
@export var visibility_padding : int = 1

@export_group("Editor Visibility")
## Click to refresh voxels in Editor
@export var refresh_voxels : bool = false:
	set(value):
		if not Engine.is_editor_hint():
			return
		if view_voxels:
			refresh_voxels = value
			if refresh_voxels:
				self.restart()
				init_voxels()
				refresh_voxels = false

## Click to view voxels in Editor
@export var view_voxels : bool = true:
	set(value):
		if not Engine.is_editor_hint():
			return
		view_voxels = value
		if view_voxels:
			init_voxels()
		else:
			self.restart()

# Start initializing voxels on ready
func _ready() -> void:
	# In Editor View start initializing with the Editor Visibility Option
	if Engine.is_editor_hint():
		view_voxels = true
	else:
		init_voxels()
	
# Voxels Initialization
func init_voxels() -> void:
	if voxelResource:
		if voxelResource.voxelAtlas:
			# If sheet numbers are set up correctly, calculate each axis' resolution for later use
			if voxelResource.slice_sheet.x > 0 and voxelResource.slice_sheet.y > 0:
				voxelResolution.x = voxelResource.voxelAtlas.get_width() / voxelResource.slice_sheet.x
				voxelResolution.y = voxelResource.voxelAtlas.get_height() / voxelResource.slice_sheet.y
				voxelResolution.z = voxelResource.slice_sheet.x * voxelResource.slice_sheet.y
				
				make_voxel()
			else:
				printerr("Voxel Resource Sheet sizes have to be greater than 0.")	
				view_voxels = false
		else:
			printerr("Voxel Atlas is empty.")
			view_voxels = false
	else:
		printerr("Voxel Resource is not set.")
		view_voxels = false

# Go through each pixel in the Voxel Atlas, and count each valid voxel, and return with the result
func calculate_voxel_count() -> int:
	var n = 0
	for y in voxelResource.voxelAtlas.get_height():
		for x in voxelResource.voxelAtlas.get_width():
			if voxelResource.voxelAtlas.get_pixel(x, y).a > 0.98:
				n += 1
	return n

func make_voxel() -> void:
	print(self.name, " has started making voxels...")
	# Set Particle count to the total voxel count
	self.amount = calculate_voxel_count()
	
	# VRZ will track which Z layer in the Voxel Atlas is drawn
	var vRZ : int
	# AABB min- and max position keeps track the particles' Min and Max position values on each axis
	# Will be used for Visibility AABB after particle emitting is completed
	var AABB_minPos : Vector3
	var AABB_maxPos : Vector3
	var first_voxel_emitted : bool = false
	

	vRZ = 0
	# PARTICLE EMITTING STARTS HERE 
	self.emitting = true
	
	# For each sheet / frame...
	for vSY in voxelResource.slice_sheet.y:
		for vSX in voxelResource.slice_sheet.x:
			# For each of their pixels...
			for vRY in voxelResolution.y:
				for vRX in voxelResolution.x:
					# Let's read their color according the atlas row reading order
					var voxelColor : Color
					if voxelResource.rowOrder == voxelResource.RowOrder.Bottom_to_Top:
						voxelColor = voxelResource.voxelAtlas.get_pixel(vSX * voxelResolution.x + 
						vRX, (((voxelResource.slice_sheet.y - 1) - vSY) * voxelResolution.y) + vRY)
					else:
						voxelColor = voxelResource.voxelAtlas.get_pixel(
							vSX * voxelResolution.x + vRX, vSY * voxelResolution.y + vRY)
					
					# If the voxel's color alpha is legitimate for voxel creation,
					# i.e. it's opaque
					if voxelColor.a > 0.99:
						
						# Let's create the particle's Transform
						var vPos = Transform3D()
						# Scale according to the Voxel Size
						vPos = vPos.scaled(Vector3.ONE * voxelSize)
						
						var vPosV3 : Vector3
						
						# Set it's Position according to it's position and pivot offset
						if !voxelResource.mirror_x:
							vPosV3.x = vRX - voxelResource.pivotOffset.x
						else:
							vPosV3.x = voxelResolution.x - 1 - vRX - voxelResource.pivotOffset.x
						
						if !voxelResource.mirror_y:
							vPosV3.y = vRY - voxelResource.pivotOffset.y
						else:
							vPosV3.y = voxelResolution.y - 1 - vRY - voxelResource.pivotOffset.y
						
						if !voxelResource.mirror_z:
							vPosV3.z = vRZ - voxelResource.pivotOffset.z
						else:
							vPosV3.z = voxelResolution.z - 1 - vRZ - voxelResource.pivotOffset.z
						
						
						
						# If this is our first voxel, set the min and max position value to it
						if !first_voxel_emitted:
							AABB_minPos = vPosV3
							AABB_maxPos = vPosV3
							first_voxel_emitted = true
						
						# Check if voxel's position is the actual min or max value on each axis
						if vPosV3.x < AABB_minPos.x:
							AABB_minPos.x = vPosV3.x
						if vPosV3.x > AABB_maxPos.x:
							AABB_maxPos.x = vPosV3.x
						if vPosV3.y < AABB_minPos.y:
							AABB_minPos.y = vPosV3.y
						if vPosV3.y > AABB_maxPos.y:
							AABB_maxPos.y = vPosV3.y
						if vPosV3.z < AABB_minPos.z:
							AABB_minPos.z = vPosV3.z
						if vPosV3.z > AABB_maxPos.z:
							AABB_maxPos.z = vPosV3.z
						
						# Position is converted from drawing coordinates (XY atlasview + Z layers) to particle's local space coordinates
						if voxelResource.draw_direction == voxelResource.DrawDirection.X_Positive:
							vPos.origin = Vector3(vPosV3.z, vPosV3.y, vPosV3.x)
						elif voxelResource.draw_direction == voxelResource.DrawDirection.X_Negative :
							vPos.origin = Vector3(-vPosV3.z, vPosV3.y, -vPosV3.x)
						elif voxelResource.draw_direction == voxelResource.DrawDirection.Y_Positive:
							vPos.origin = Vector3(vPosV3.y, vPosV3.z, -vPosV3.x)
						elif voxelResource.draw_direction == voxelResource.DrawDirection.Y_Negative :
							vPos.origin = Vector3(vPosV3.y, -vPosV3.z, vPosV3.x)
						elif voxelResource.draw_direction == voxelResource.DrawDirection.Z_Positive:
							vPos.origin = Vector3(-vPosV3.x, vPosV3.y, vPosV3.z)
						else:
							vPos.origin = Vector3(vPosV3.x, vPosV3.y, -vPosV3.z)
						
						# No need for velocity
						var velocity = Vector3.ZERO
						# No need for custom colors (might be subject to change)
						var custom = Color(0,0,0,1)
						# Scale particle system to Voxel Scale
						self.scale = Vector3.ONE * voxelScale
						# Emit this particle!
						self.emit_particle(vPos, velocity, voxelColor, custom, 1 | 2 | 4 | 8 | 16)
						
						
			# Step to next Atlas layer
			vRZ += 1

	#Once we are done, stop emitting!
	self.emitting = false
	
	print(self.name, " has finished making voxels!")
	
	#CREATING A NEW AABB TO REPLACE PARTICLE'S VISIBILITY AABB
	var calcAABB = AABB()
	
	#SIZE is calculated from
	#SIZE VOLUME -> Maximum vector positions - Minimum vector positions
	#PLUS 2 TIMES THE VISIBILITY PADDING
	var AABB_size = Vector3(AABB_maxPos-AABB_minPos+(Vector3.ONE*visibility_padding*2))
	
	#Position is calculated from
	#SIZE VOLUME -> Maximum vector positions - Minimum vector positions
	#HALVED -> To ensure it will be in the middle of volume
	#ADDED MINPOS -> To offset position center
	var AABB_pos = Vector3((AABB_maxPos-AABB_minPos)*0.5+AABB_minPos)
	
	# Convert AABB position and size to local coordinates
	if voxelResource.draw_direction == voxelResource.DrawDirection.X_Positive:
		calcAABB.position = Vector3(AABB_pos.z-AABB_size.z/2, AABB_pos.y-AABB_size.y/2, AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.z, AABB_size.y, AABB_size.x)
	elif voxelResource.draw_direction == voxelResource.DrawDirection.X_Negative:
		calcAABB.position = Vector3(-AABB_pos.z-AABB_size.z/2, AABB_pos.y-AABB_size.y/2, -AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.z, AABB_size.y, AABB_size.x)
	elif voxelResource.draw_direction == voxelResource.DrawDirection.Y_Positive:
		calcAABB.position = Vector3(AABB_pos.y-AABB_size.y/2, AABB_pos.z-AABB_size.z/2, -AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.y, AABB_size.z, AABB_size.x)
	elif voxelResource.draw_direction == voxelResource.DrawDirection.Y_Negative:
		calcAABB.position = Vector3(AABB_pos.y-AABB_size.y/2, -AABB_pos.z-AABB_size.z/2, AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.y, AABB_size.z, AABB_size.x)
	elif voxelResource.draw_direction == voxelResource.DrawDirection.Z_Positive:
		calcAABB.position = Vector3(-AABB_pos.x-AABB_size.x/2, AABB_pos.y-AABB_size.y/2, AABB_pos.z-AABB_size.z/2)
		calcAABB.size = Vector3(AABB_size.x, AABB_size.y, AABB_size.z)	
	else:
		calcAABB.position = Vector3(AABB_pos.x-AABB_size.x/2, AABB_pos.y-AABB_size.y/2, -AABB_pos.z-AABB_size.z/2)
		calcAABB.size = Vector3(AABB_size.x, AABB_size.y, AABB_size.z)

	# Set new visibility AABB values
	self.visibility_aabb = calcAABB
