@tool
extends Node3D
class_name VoxelSprite

var voxel_mesh = preload("res://resources/voxel_mesh.tres")

@onready var voxels: Node3D = $Voxels
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var spritesheet : Texture2D

@export var default_animation : StringName

@export var h_frames : int
@export var v_frames : int

@export var fps : int = 10 : 
	set(value):
		fps = clamp(value, 1, 30)
		animation_player.speed_scale = fps / 10.0
		
@export var voxel_size : Vector3 = Vector3(0.0, 0.0, 0.0) 

@export var animated : bool = true

var multi_mesh_instance: MultiMeshInstance3D

var animations : PackedStringArray = []

var region_size : Vector2

var voxel_grid : Dictionary = {}

var frame_images : Array[Image] = []

var current_animation : StringName

@export var anim_frame : int = 0
var last_frame : int = 0

var loop_count : int = 0

var elapsed_time : float = 0.0


signal animation_finished(_anim_name : StringName)

func _ready() -> void:
#Creating the multimesh in code to avoid buffer error in Vulkan renderer
	var mmesh = MultiMesh.new()
	mmesh.instance_count = 0
	mmesh.transform_format = MultiMesh.TRANSFORM_3D
	mmesh.use_custom_data = true
	mmesh.mesh = voxel_mesh
	
	multi_mesh_instance = MultiMeshInstance3D.new()
	multi_mesh_instance.multimesh = mmesh
	
	$Voxels.add_child.call_deferred(multi_mesh_instance)
	
	if !spritesheet or h_frames == 0 or v_frames == 0:
		set_process(false)
		return

	set_process(animated)

	region_size = calculate_region_size()

	create_images()

	animations = animation_player.get_animation_list()
	var r : int = animations.find("RESET")
	animations.remove_at(r)
	print(animations)
	current_animation = default_animation
	
	update_voxels()
	change_anim_to(default_animation)


#Calculate the size of a single frame
func calculate_region_size() -> Vector2:
	return Vector2(spritesheet.get_width() / h_frames, spritesheet.get_height() / v_frames)

#Change animation to a given one
func change_anim_to(anim_name : StringName, speed_scale = 1.0):
	animation_player.speed_scale = speed_scale
	animation_player.play(anim_name)
	current_animation = anim_name

func next_anim():
	if animations.size() <= 1:
		return
	var cur_anim = animations.find(current_animation)
	change_anim_to(animations[wrapi(cur_anim + 1, 0, animations.size())])

func prev_anim():
	if animations.size() <= 1:
		return
	var cur_anim = animations.find(current_animation)
	change_anim_to(animations[wrapi(cur_anim - 1, 0, animations.size())])
	
#Extract individual image data from the spritesheet and put them in an Array
func create_images():
	var spritesheet_image = spritesheet.get_image()
	for y in v_frames:
		for x in h_frames:
			var region_rect : Rect2 = Rect2(Vector2(x * region_size.x, y * region_size.y), region_size)
			var frame_img : Image = spritesheet_image.get_region(region_rect)
			
			frame_images.append(frame_img)

	
#Create the voxel representation of the image
func update_voxels():
	var image : Image = frame_images[anim_frame]
	get_color_pixels(image)

	multi_mesh_instance.multimesh.instance_count = 0
	multi_mesh_instance.multimesh.use_custom_data = true
	multi_mesh_instance.multimesh.mesh.size = voxel_size
	multi_mesh_instance.multimesh.instance_count = voxel_grid.size()
	
	var instance_count : int = 0
	for coord in voxel_grid.keys():
		var xform : Transform3D = Transform3D(Basis.IDENTITY, Vector3(coord.x * voxel_size.x, -coord.y * voxel_size.y, 0) + Vector3((-region_size.x / 2.0) * voxel_size.x, (region_size.y / 2.0) * voxel_size.y, 0))
		multi_mesh_instance.multimesh.set_instance_transform(instance_count, xform)
		multi_mesh_instance.multimesh.set_instance_custom_data(instance_count, voxel_grid[coord])
		instance_count += 1
	
#Filter out fully empty pixels
func get_color_pixels(img : Image):
	voxel_grid = {}
	for y in img.get_height():
		for x in img.get_width():
			var pixel_color = img.get_pixel(x, y)
			if pixel_color.a > 0:
				voxel_grid[Vector2(x, y)] = pixel_color

func _process(delta: float) -> void:
	if last_frame != anim_frame:
		update_voxels()
		last_frame = anim_frame
