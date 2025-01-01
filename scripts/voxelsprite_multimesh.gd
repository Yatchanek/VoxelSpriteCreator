@tool
extends Node3D
class_name VoxelSpriteMultiMesh

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var voxel_grid: MultiMeshInstance3D = $VoxelGrid

@export_category("Textures")
@export var spritesheet : Texture2D
@export var color_texture : Texture2D
@export var position_offset_texture : Texture2D

@export_category("Animation settings")
@export var default_animation : StringName

@export var h_frames : int
@export var v_frames : int

@export var fps : int = 10 : 
	set(value):
		fps = clamp(value, 1, 30)
		if is_instance_valid(animation_player):
			animation_player.speed_scale = fps / 10.0
@export_category("Other settings")	
@export var voxel_size : Vector3 = Vector3(0.04, 0.04, 0.08):
	set(value):
		if is_instance_valid(voxel_grid):
			voxel_size = value
			voxel_grid.material_override.set_shader_parameter("voxel_size", voxel_size)

@export var animated : bool = true

var animations : PackedStringArray = []

var region_size : Vector2i

var current_animation : StringName

var position_offset_scale : float

@export var anim_frame : int = 0 :
	set(value):
		anim_frame = value
		if is_instance_valid(voxel_grid):
			voxel_grid.material_override.set_shader_parameter("anim_frame", anim_frame)
		
var texture_width : int = 0

signal animation_finished(_anim_name : StringName)

func _ready() -> void:
	if !spritesheet or h_frames == 0 or v_frames == 0:
		return

	region_size = calculate_region_size()
	
	#If textures for animation are not provided, create them
	if !color_texture or !position_offset_texture:
		#Index 0 - color texure, index 1 - positions texture
		var images : Array[Image] = create_images()
		color_texture = ImageTexture.create_from_image(images[0])
		position_offset_texture = ImageTexture.create_from_image(images[1])
		
	#Width of the texture is used to calculate the number of cubes needed
	#It corresponds to the highest number of solid pixels in all frames
	texture_width = color_texture.get_width()
		
	#Configure Multimesh
	voxel_grid.multimesh.instance_count = 0
	voxel_grid.multimesh.use_custom_data = true
	voxel_grid.multimesh.instance_count = texture_width
	
	for i in texture_width:
		voxel_grid.multimesh.set_instance_custom_data(i, Color(i, i, i, i))
		voxel_grid.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, 0, 0)))
	
	#Configure the shader material
	voxel_grid.material_override = ShaderMaterial.new()
	voxel_grid.material_override.shader = load("res://resources/vertex_animation_shader_m.gdshader")

	voxel_grid.material_override.set_shader_parameter("colors", color_texture)
	voxel_grid.material_override.set_shader_parameter("positions", position_offset_texture)
	voxel_grid.material_override.set_shader_parameter("voxel_size", voxel_size)
	voxel_grid.material_override.set_shader_parameter("x_resolution", region_size.x)
	voxel_grid.material_override.set_shader_parameter("y_resolution", region_size.y)
		
	animations = animation_player.get_animation_list()
	
	#Remove the Reset animation from animation array
	var idx = animations.find("RESET")
	animations.remove_at(idx)
	
	current_animation = default_animation
	
	if current_animation:
		change_anim_to(current_animation, fps / 10.0)


				
#Create images for color and position offsets
func create_images() -> Array[Image]:
	var images : Array[Image] = []
	var spritesheet_image : Image = spritesheet.get_image()
	var longest_frame : int = 0
	
	var color_array : Array[PackedByteArray] = []
	var pos_array : Array[PackedByteArray] = []
	
	#Loop through all the frames
	for y in v_frames:
		for x in h_frames:
			var region_rect : Rect2 = Rect2(Vector2(x * region_size.x, y * region_size.y), region_size)
			var frame_img : Image = spritesheet_image.get_region(region_rect)			
			
			var color_data : PackedByteArray = []
			var pos_data : PackedByteArray = []
			var pixel_count : int = 0
			
			#Get raw frame data
			var frame_data : PackedByteArray = frame_img.get_data()
			
			#Loop through pixels (4 bytes for 1 pixel)
			#If the last byte is not equal to 0 (=solid pixel),
			#Append the 4 bytes to color data
			#And the position (calculated from pixel index in array) to position data		
			for idx in range(0, frame_data.size(), 4):
				if frame_data[idx + 3] != 0.0:
					color_data.append_array(frame_data.slice(idx, idx + 4))
					pos_data.append_array([
						(idx / 4) % region_size.x, (idx / 4) / region_size.x, 0, 255
					])
		
			pixel_count = pos_data.size()
			color_array.append(color_data)
			pos_array.append(pos_data)
	
	#Find the frame with most solid pixels		
			if pixel_count > longest_frame:
				longest_frame = pixel_count

	#Fill the shorter arrays with 0s, to match the texture width
	#Then create the image
	var raw_data : PackedByteArray = []
	var raw_data_pos : PackedByteArray = []
	for i in color_array.size():
		color_array[i].resize(longest_frame)
		pos_array[i].resize(longest_frame)
		raw_data.append_array(color_array[i])
		raw_data_pos.append_array(pos_array[i])


	images.append(Image.create_from_data(longest_frame / 4, h_frames * v_frames, false, Image.FORMAT_RGBA8, raw_data))
	images.append(Image.create_from_data(longest_frame / 4, h_frames * v_frames, false, Image.FORMAT_RGBA8, raw_data_pos))
	
	return images
		
#Calculate the size of a single frame
func calculate_region_size() -> Vector2i:
	return Vector2i(spritesheet.get_width() / h_frames, spritesheet.get_height() / v_frames)


func next_anim():
	if animations.size() < 2:
		return
	var idx : int = animations.find(current_animation)
	change_anim_to(animations[wrapi(idx + 1, 0, animations.size())], fps / 10)

func prev_anim():
	if animations.size() < 2:
		return
	var idx : int = animations.find(current_animation)
	change_anim_to(animations[wrapi(idx - 1, 0, animations.size())], fps / 10)

#Change animation to a given one
func change_anim_to(anim_name : StringName, speed_scale = 1.0):
	animation_player.speed_scale = speed_scale
	animation_player.play(anim_name)
	current_animation = anim_name
