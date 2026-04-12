# VOXEL MAKER v1.0
# Makes Particle System Voxels from Voxel Resource Objects
# Created by László Savanya - 2026

# Feel free to use in your personal or commercial project
# Credits mention is not mandantory, but much appreciated! :) 

@tool
extends GPUParticles3D

var voxelResolution : Vector3i
var zPositive : bool

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
## Click to create voxels in Editor
@export var view_voxels : bool = true:
	set(value):
		view_voxels = value
		if not Engine.is_editor_hint():
			return
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
	# If sheet numbers are set up correctly, calculate each axis' resolution for later use
	if voxelResource.sheet.x > 0 and voxelResource.sheet.y > 0:
		voxelResolution.x = voxelResource.voxelAtlas.get_width() / voxelResource.sheet.x
		voxelResolution.y = voxelResource.voxelAtlas.get_height() / voxelResource.sheet.y
		voxelResolution.z = voxelResource.sheet.x * voxelResource.sheet.y
		
		# In a later stage, we need to know if Spriteview is set to Positive or Negative
		zPositive = voxelResource.spriteView == voxelResource.SpriteView.X_Positive or voxelResource.spriteView == voxelResource.SpriteView.Y_Positive or voxelResource.spriteView == voxelResource.SpriteView.Z_Positive
		make_voxel()
	else:
		printerr("Voxel Resource Sheet sizes have to be greater than 0")	

# Go through each pixel in the Voxel Atlas, and count each valid voxel, and return with the result
func calculate_voxel_count() -> int:
	var n = 0
	for y in voxelResource.voxelAtlas.get_height():
		for x in voxelResource.voxelAtlas.get_width():
			if voxelResource.voxelAtlas.get_pixel(x, y).a > 0.98:
				n += 1
	return n

func make_voxel() -> void:
	# Set Particle count to the total voxel count
	self.amount = calculate_voxel_count()
	
	# VRZ will track which Z layer in the Voxel Atlas is drawn
	var vRZ : int
	# AABB min- and max position keeps track the particles' Min and Max position values on each axis
	# Will be used for Visibility AABB after particle emitting is completed
	var AABB_minPos : Vector3
	var AABB_maxPos : Vector3
	var first_voxel_emitted : bool = false
	
	# Z Positive determines if we are drawing each layer from front to back or vice versa
	if zPositive:
		vRZ = 0
	else:
		vRZ = voxelResolution.z
	
	# PARTICLE EMITTING STARTS HERE 
	self.emitting = true
	
	# For each sheet / frame...
	for vSY in voxelResource.sheet.y:
		for vSX in voxelResource.sheet.x:
			# For each of their pixels...
			for vRY in voxelResolution.y:
				for vRX in voxelResolution.x:
					# Let's read their color according the atlas row reading order
					var voxelColor : Color
					if voxelResource.rowOrder == voxelResource.RowOrder.Bottom_to_Top:
						voxelColor = voxelResource.voxelAtlas.get_pixel(vSX * voxelResolution.x + 
						vRX, (((voxelResource.sheet.y - 1) - vSY) * voxelResolution.y) + vRY)
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
						# Set it's Position according to it's position and pivot offset
						var x = -vRX + voxelResolution.x - 1 + voxelResource.pivotOffset.x
						var y = -vRY + voxelResolution.y - 1 + voxelResource.pivotOffset.y
						var z = vRZ + voxelResource.pivotOffset.z
						
						# If this is our first voxel, set the min and max position value to it
						if !first_voxel_emitted:
							AABB_minPos = Vector3(x, y, z)
							AABB_maxPos = Vector3(x, y, z)
							first_voxel_emitted = true
						
						# Check if voxel's position is the actual min or max value on each axis
						if x < AABB_minPos.x:
							AABB_minPos.x = x
						if x > AABB_maxPos.x:
							AABB_maxPos.x = x
						if y < AABB_minPos.y:
							AABB_minPos.y = y
						if y > AABB_maxPos.y:
							AABB_maxPos.y = y
						if z < AABB_minPos.z:
							AABB_minPos.z = z
						if z > AABB_maxPos.z:
							AABB_maxPos.z = z
						
						# Position is converted from drawing coordinates (XY atlasview + Z layers) to particle's local space coordinates
						if voxelResource.spriteView == voxelResource.SpriteView.X_Positive or voxelResource.spriteView == voxelResource.SpriteView.X_Negative:
							vPos.origin = Vector3(z, y, -x)
						elif voxelResource.spriteView == voxelResource.SpriteView.Y_Positive or voxelResource.spriteView == voxelResource.SpriteView.Y_Negative:
							vPos.origin = Vector3(y, z, -x)
						else:
							vPos.origin = Vector3(x, y, z)
						
						# No need for velocity
						var velocity = Vector3.ZERO
						# No need for custom colors (might be subject to change)
						var custom = Color(0,0,0,1)
						# Scale particle system to Voxel Scale
						self.scale = Vector3.ONE * voxelScale
						# Emit this particle!
						self.emit_particle(vPos, velocity, voxelColor, custom, 1 | 2 | 4 | 8 | 16)
						
						
			# Step to next Atlas layer
			if zPositive:
				vRZ += 1
			else:
				vRZ -= 1
	#Once we are done, stop emitting!
	self.emitting = false
	
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
	if voxelResource.spriteView == voxelResource.SpriteView.X_Positive or voxelResource.spriteView == voxelResource.SpriteView.X_Negative:
		calcAABB.position = Vector3(AABB_pos.z-AABB_size.z/2, AABB_pos.y-AABB_size.y/2, -AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.z, AABB_size.y, AABB_size.x)
	elif voxelResource.spriteView == voxelResource.SpriteView.Y_Positive or voxelResource.spriteView == voxelResource.SpriteView.Y_Negative:
		calcAABB.position = Vector3(AABB_pos.y-AABB_size.y/2, AABB_pos.z-AABB_size.z/2, -AABB_pos.x-AABB_size.x/2)
		calcAABB.size = Vector3(AABB_size.y, AABB_size.z, AABB_size.x)
	else:
		calcAABB.position = Vector3(AABB_pos.x-AABB_size.x/2, AABB_pos.y-AABB_size.y/2, AABB_pos.z-AABB_size.z/2)
		calcAABB.size = Vector3(AABB_size.x, AABB_size.y, AABB_size.z)

	# Set new visibility AABB values
	self.visibility_aabb = calcAABB
