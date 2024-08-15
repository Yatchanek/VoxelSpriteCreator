extends Node3D

@onready var pivot: Marker3D = $Pivot
@onready var voxel_sprite: VoxelSprite = $Pivot/VoxelSprite as VoxelSprite

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

