A simple image-to-voxel converter.

It takes a spritesheet, extracts the data and creates a 3D representation. The VoxelSprite can then be animated by changing the anim_frame value via AnimationPlayer (or by code if you prefer it this way).

The implementation uses Multimesh Instance, so all the voxels can be drawn in a single draw call. The Multimesh and the meshes are created in code instead of the inspector to avoid annoying error messages in the editor about instance count being > 0 and about an empty buffer.

I've included a simple demo scene. 

The spritesheet must be imported as uncompressed (Lossless, VRAM Uncompressed etc.) in order to work.

The VoxelSprite can create textures upon loading, but it's more efficient to provide them beforehand.
I have provided a simple texture creator tool, but you can also use the VoxelSprite itself - after the first use it will generate the textures. 

*Add the @tool verse at the beginning of the voxelsprite sctipt to make the result visible in the editor.

!!! Sometimes Godot automatically detects that the color/position texture will be used in 3D and sets it to VRAM Compressed. Reimport it as VRAM Uncompressed or Lossless, otherwise it may not display correctly.

Current limitations:
- No support for transparent pixels.
- 256x256 px size limit.

Credits:
Warrior sprite by Clembod.

MIT license. Use it for whatever you want.
