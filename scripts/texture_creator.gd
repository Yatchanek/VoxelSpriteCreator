extends Node

@onready var file_dialog: FileDialog = $CanvasLayer/Control/FileDialog
@onready var spritesheet_view: TextureRect = %SpritesheetView
@onready var create_button: Button = %CreateButton
@onready var save_color: Button = %SaveColor
@onready var save_position: Button = %SavePosition
@onready var color_texture_rect: TextureRect = %ColorTexture
@onready var position_texture_rect: TextureRect = %PositionTexture


var h_frames : int
var v_frames : int

var spritesheet : Texture2D
var region_size : Vector2i

var color_texture : Texture2D
var position_texture : Texture2D

var saving_color : bool = false
var saving_postion : bool = false

func _ready() -> void:
	pass

func calculate_region_size() -> Vector2i:
	return Vector2i(spritesheet.get_width() / h_frames, spritesheet.get_height() / v_frames)

func create_images() -> void:
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
				if frame_data[idx] != 0.0:
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
		
	var output_image : Image = Image.create_from_data(longest_frame / 4, h_frames * v_frames, false, Image.FORMAT_RGBA8, raw_data)
	color_texture = ImageTexture.create_from_image(output_image)
	
	output_image = Image.create_from_data(longest_frame / 4, h_frames * v_frames, false, Image.FORMAT_RGBA8, raw_data_pos)
	position_texture = ImageTexture.create_from_image(output_image)

	color_texture_rect.texture = color_texture
	position_texture_rect.texture = position_texture
	
	save_color.disabled = false
	save_position.disabled = false

func _on_file_dialog_file_selected(path: String) -> void:
	if !saving_color and !saving_postion:
		var f : FileAccess = FileAccess.open(path, FileAccess.READ)
		var image_buffer : PackedByteArray = f.get_buffer(f.get_length())
		var img : Image = Image.new()
		img.load_png_from_buffer(image_buffer)
		spritesheet = ImageTexture.create_from_image(img)
		
		spritesheet_view.texture = spritesheet

		create_button.disabled = false
	elif saving_postion:
		var img : Image = position_texture.get_image()
		img.save_png(path)
	elif saving_color:
		var img : Image = color_texture.get_image()
		img.save_png(path)

func _on_button_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.popup_centered()


func _on_hframes_value_changed(value: float) -> void:
	h_frames = int(value)



func _on_vframes_value_changed(value: float) -> void:
	v_frames = int(value)


func _on_create_button_pressed() -> void:
	region_size = calculate_region_size()
	create_images()


func _on_save_color_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	saving_color = true
	saving_postion = false
	file_dialog.current_file = "color_texture.png"
	file_dialog.popup_centered()


func _on_save_position_pressed() -> void:
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	saving_color = false
	saving_postion = true
	file_dialog.current_file = "position_texture.png"
	file_dialog.popup_centered()


func _on_quit_pressed() -> void:
	get_tree().quit()
