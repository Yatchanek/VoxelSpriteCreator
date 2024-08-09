A simple image-to-voxel converter.

It takes a spritesheet, extracts the data and creates a 3D representation. The VoxelSprite can then be animated by changing the anim_frame value via AnimationPlayer (or by code if you prefer it this way).

MultiMeshInstance is used to produce the voxels, so the whole VoxelSprite is drawn in one draw call. However, because each voxel is a separate BoxMesh, their number is quite high. The sprite used in this demo uses from 400 to 900 meshes depending on the frame. If I were smarter, I probably could find a way to use some greedy meshing to lump voxels of the same colour. Anyway, on a modern machine, using a couple of VoxelSprites at once shouldn't be a problem.

The latest version cashes all the voxel grids of a spritesheet (a dictionary with coordinates and colour of each voxel) at the beginning, instead of reading the pixels from the sprite region each time the voxels update. I hope it improves the performance a bit.

I'm a noob when it comes to shaders and lightning, so no matter how hard I try, I cannot get the exact same colours as in the spritesheet. Maybe some of you can do it better.

I've included a simple demo scene. Because the sprite I used is not centered, the rotation will get weird if you change the X size of voxels.

The spritesheet must be imported as uncompressed (Lossless, VRAM Uncompressed etc.) in order to work.

Credits:
Warrior sprite by Clembod.

MIT license. Use it for whatever you want.
