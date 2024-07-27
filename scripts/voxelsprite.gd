@tool
extends Node3D
class_name VoxelSprite


@onready var voxels: Node3D = $Voxels
@onready var multi_mesh: MultiMeshInstance3D = $Voxels/MultiMesh

@export var animations : Array[AnimData] = []
@export var spritesheet : Texture2D

@export var default_animation : StringName

@export var h_frames : int
@export var v_frames : int

@export var fps : int = 10 : 
	set(value):
		fps = clamp(value, 1, 30)
		frame_duration = 1.0 / fps

var region_size : Vector2


@export var voxel_size : Vector3 = Vector3(0.1, 0.1, 0.1) 

var voxel_grid : Dictionary = {}

var animation_dict : Dictionary = {}

var frame_images : Array[Image] = []
var normals_images : Array[Image] = []

var current_animation : AnimData
var anim_tick : int = 0

var elapsed_time : float = 0.0

var frame_duration : float = 0.0


func _ready() -> void:
	
	if !spritesheet or h_frames == 0 or v_frames == 0:
		set_process(false)
		return

	region_size = calculate_region_size()

	create_images()
	create_anim_dict()
	
	frame_duration = 1.0 / fps

	if !default_animation or !animation_dict.has(default_animation):
		if animations.size() > 0:
			current_animation = animations[0]
		else:
			set_process(false)
	else:
		change_anim(default_animation)
	
	update_voxels(current_animation, anim_tick)


#Calculate the size of a single frame
func calculate_region_size() -> Vector2:
	return Vector2(spritesheet.get_width() / h_frames, spritesheet.get_height() / v_frames)

#Change animation to a given one
func change_anim(anim_name : StringName):
	if !animation_dict.has(anim_name):
		return
		
	current_animation = animation_dict[anim_name]
	anim_tick = current_animation.begin_frame

#Next animation
func next_anim():
	if animations.size() < 2:
		return
	var idx : int = animations.find(current_animation)
	current_animation = animations[wrapi(idx + 1, 0, animations.size())]
	anim_tick = current_animation.begin_frame

#Previous animation	
func prev_anim():
	if animations.size() < 2:
		return
	var idx : int = animations.find(current_animation)
	current_animation = animations[wrapi(idx - 1, 0, animations.size())]
	anim_tick = current_animation.begin_frame	

#Put animations in a directory to access them by name
func create_anim_dict():
	for anim : AnimData in animations:
		animation_dict[anim.anim_name] = anim
		
#Extract individual image data from the spritesheet and put them in an Array
func create_images():
	var spritesheet_image = spritesheet.get_image()
	for y in v_frames:
		for x in h_frames:
			var region_rect : Rect2 = Rect2(Vector2(x * region_size.x, y * region_size.y), region_size)
			var frame_img : Image = spritesheet_image.get_region(region_rect)
			
			frame_images.append(frame_img)

	
#Create the voxel representation of the image	
func update_voxels(animation : AnimData, _anim_tick : int):
	var current_frame : int = _anim_tick
	if !animation:
		current_frame = 0
	
	var image : Image = frame_images[current_frame]
	get_color_pixels(image)

	multi_mesh.multimesh.instance_count = 0
	multi_mesh.multimesh.use_custom_data = true
	multi_mesh.multimesh.mesh.size = voxel_size
	multi_mesh.multimesh.instance_count = voxel_grid.size()
	
	var instance_count : int = 0
	for coord in voxel_grid.keys():
		var xform : Transform3D = Transform3D(Basis.IDENTITY, Vector3(coord.x * voxel_size.x, -coord.y * voxel_size.y, 0) + Vector3((-region_size.x / 2.0) * voxel_size.x, (region_size.y / 2.0) * voxel_size.y, 0))
		multi_mesh.multimesh.set_instance_transform(instance_count, xform)
		multi_mesh.multimesh.set_instance_custom_data(instance_count, voxel_grid[coord])
		instance_count += 1
		
	
func get_color_pixels(img : Image):
	voxel_grid = {}
	for y in img.get_height():
		for x in img.get_width():
			var pixel_color = img.get_pixel(x, y)
			if pixel_color.a > 0:
				voxel_grid[Vector2(x, y)] = pixel_color

#We do animation here						
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= frame_duration:
		anim_tick = wrapi(anim_tick + 1, current_animation.begin_frame, current_animation.end_frame + 1)
		elapsed_time = 0
		update_voxels(current_animation, anim_tick)


