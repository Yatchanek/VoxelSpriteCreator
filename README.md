A simple image-to-voxel converter.

It takes a spritesheet, extracts the data and creates a 3D representation. The VoxelSprite can then be animated by changing the anim_frame value via AnimationPlayer (or by code if you prefer it this way).

Thanks to u/DNCGame from Reddit, I switched to vertex animation. First, the VoxelSprite creates two textures: one containing positon offsets of the pixels (only solid ones), the other containing colors of those pixels for each frame. Then, I create ArrayMesh with a number of cubes corresponding to the highest number of pixels in all the frames. The shader reads the positions and colors for each cube, using the UV.x channel. 

I've introduced MultiMesh again instead of creating the mesh in code. It still has more primitives than my previous pure MultiMesh approach, as the maximum number of cubes needed is generated (the included sprite requires about 12500 primitives - not something a modern GPU cannot handle), but moving and coloring the cubes via GPU should be faster than doing it in GDScript for each instance of the MultiMesh. Also, using MultiMesh is much faster than generating the mesh in code.

I've included a simple demo scene. 

The spritesheet must be imported as uncompressed (Lossless, VRAM Uncompressed etc.) in order to work.

The VoxelSprite can create textures upon loading, but it's more efficient to provide them befhrehand (in the demo example, it takes about 133ms to load when there are no textures, compared to about 30 with textures).
I have provided a simple texture creator tool, but you can also use the VoxelSprite itself. As it's a @tool script, if provided with a spritesheet and corretly set h_frames and v_frames, it will generate textures when opened in the editor. You can then save them for later use.

!!! Sometimes Godot automatically detects that the color/position texture will be used in 3D and sets it to VRAM Compressed. Reimport it as VRAM Uncompressed or Lossless, otherwise it may not display correctly.


Credits:
Warrior sprite by Clembod.

MIT license. Use it for whatever you want.
