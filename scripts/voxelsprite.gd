@tool
extends Node3D
class_name VoxelSprite


@onready var voxels: Node3D = $Voxels
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


@export var voxel_size : Vector3 = Vector3(0.1, 0.1, 0.1) :
	set(value):
		var changed : bool = !voxel_size.is_equal_approx(value)
		voxel_size = value
		if changed:
			destroy_voxels()
			update_voxels(current_animation, anim_tick)

var voxel_grid : Dictionary = {}

var materials : Dictionary = {}

var animation_dict : Dictionary = {}

var frame_images : Array[Image] = []

var current_animation : AnimData
var anim_tick : int = 0

var elapsed_time : float = 0.0

var frame_duration : float = 0.0


func _ready() -> void:
	if !spritesheet or h_frames == 0 or v_frames == 0:
		return

	region_size = calculate_region_size()

	create_images()
	create_materials()
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

#Remove all the voxels			
func destroy_voxels():
	voxel_grid = {}
	for voxel in voxels.get_children():
		voxel.queue_free()
	
#Create the voxel representation of the image	
func update_voxels(animation : AnimData, anim_tick : int):
	var current_frame : int = anim_tick
	if !animation:
		current_frame = 0
	
	#Get raw image data
	var data : PackedByteArray = frame_images[current_frame].get_data()

	for y in region_size.y:
		for x in region_size.x:
			#Check if a pixel is fully transparent
			if data[(y * region_size.x + x) * 4 + 3] > 0:
				var pixel_color : Color = Color(data[(y * region_size.x + x) * 4] / 255.0, (data[(y * region_size.x + x) * 4 + 1] ) / 255.0, (data[(y * region_size.x + x) * 4 + 2]) / 255.0, (data[(y * region_size.x + x) * 4 + 3]) / 255.0)

				#Check if voxel already created. If not create it
				if !voxel_grid.has(Vector2(x, y)):
					var voxel : MeshInstance3D = MeshInstance3D.new()
					var mesh : BoxMesh = voxel.mesh as BoxMesh
					mesh = BoxMesh.new()
					mesh.size = voxel_size
					voxel.mesh = mesh
					voxel.position = Vector3(x * voxel_size.x, -y * voxel_size.y, 0) + Vector3((-region_size.x / 2.0) * voxel_size.x, (region_size.y / 2.0) * voxel_size.y, 0)	
					voxel_grid[Vector2(x, y)] = voxel
					
					mesh.material = materials[pixel_color]

					voxel.show()
					voxels.add_child(voxel)
				
				#If voxel exists, check if the color matches the image
				#If not, update it	
				else:
					voxel_grid[Vector2(x, y)].show()
					var mesh : BoxMesh = voxel_grid[Vector2(x, y)].mesh
					if mesh.material != materials[pixel_color]:
						mesh.material = materials[pixel_color]

				
					
			#If pixel is tranparent and voxel exists, hide it
			elif voxel_grid.has(Vector2(x, y)):
				voxel_grid[Vector2(x, y)].hide()

#We do animation here						
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= frame_duration:
		anim_tick = wrapi(anim_tick + 1, current_animation.begin_frame, current_animation.end_frame + 1)
		elapsed_time = 0
		update_voxels(current_animation, anim_tick)

#Create StandardMaterial for each pixel color
#It is also possible to skip it and work with albedo_color directly,
#It requires a small refactor of the update_voxels function
func create_materials():
	for img : Image in frame_images:
		#Get raw image data
		var data : PackedByteArray = img.get_data()
		
		for j in range(0, data.size() - 4):
			if data[j + 4] > 0:
				var pixel_color : Color = Color(data[j] / 255.0, data[j + 1] / 255.0, data[j + 2] / 255.0, data[j + 3] / 255.0)
				
				#Check if material already exists for this color
				if !materials.has(pixel_color):
					var material : StandardMaterial3D = StandardMaterial3D.new()
					material.albedo_color = pixel_color
					
					materials[pixel_color] = material		

