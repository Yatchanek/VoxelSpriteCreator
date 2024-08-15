A simple image-to-voxel converter.

It takes a spritesheet, extracts the data and creates a 3D representation. The VoxelSprite can then be animated by changing the anim_frame value via AnimationPlayer (or by code if you prefer it this way).

Thanks to u/DNCGame from Reddit, I switched to vertex animation. First, the VoxelSprite creates two textures: one containing positon offsets of the pixels (only solid ones), the other containing colors of those pixels for each frame. Then, I create ArrayMesh with a number of cubes corresponding to the highest number of pixels in all the frames. The shader reads the positions and colors for each cube, using the UV.x channel. 

This method generates more primitive to draw than the earlier MultiMesh approach, but moving and coloring the cubes via GPU should be faster than doing it in GDScript for each instance of the MultiMesh.

I've included a simple demo scene. 

The spritesheet must be imported as uncompressed (Lossless, VRAM Uncompressed etc.) in order to work.

Credits:
Warrior sprite by Clembod.

MIT license. Use it for whatever you want.
