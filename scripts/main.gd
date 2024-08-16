extends Node3D

@onready var pivot: Marker3D = $Pivot
@onready var voxel_sprite: VoxelSprite = $Pivot/VoxelSprite as VoxelSprite
@onready var x_slider: HSlider = $CanvasLayer/HUD/MarginContainer/VBoxContainer/HBoxContainer3/XSlider
@onready var y_slider: HSlider = $CanvasLayer/HUD/MarginContainer/VBoxContainer/HBoxContainer4/YSlider
@onready var z_slider: HSlider = $CanvasLayer/HUD/MarginContainer/VBoxContainer/HBoxContainer5/ZSlider

var rotation_speed : float = PI :
	set(value):
		rotation_speed = clamp(value, -TAU, TAU)

var angle : float = 0



func _process(delta: float) -> void:
	angle += rotation_speed * delta * .1
	pivot.rotation.y = angle #PI / 3 * sin(angle)


func _on_next_anim_pressed() -> void:
	voxel_sprite.next_anim()


func _on_prev_anim_pressed() -> void:
	voxel_sprite.prev_anim()


func _on_fps_down_pressed() -> void:
	voxel_sprite.fps -= 1
	

func _on_fps_up_pressed() -> void:
	voxel_sprite.fps += 1


func _on_rotate_slower_pressed() -> void:
	self.rotation_speed -= PI * 0.1
	
func _on_rotate_faster_pressed() -> void:
	self.rotation_speed += PI * 0.1



func _on_z_slider_value_changed(value: float) -> void:
	voxel_sprite.voxel_size.z = value


func _on_y_slider_value_changed(value: float) -> void:
	voxel_sprite.voxel_size.y = value


func _on_x_slider_value_changed(value: float) -> void:
	voxel_sprite.voxel_size.x = value
