extends Node3D

@onready var voxel_sprite: VoxelSprite = $VoxelSprite

var move_direction : float

func _process(delta: float) -> void:
	var move_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if abs(move_direction) > 0.01:
		voxel_sprite.change_anim(&"Run")
		if move_direction < 0:
			voxel_sprite.rotation.y = PI
		else:
			voxel_sprite.rotation.y = 0
	else:
		voxel_sprite.change_anim(&"Idle")
		
