A simple image-to-voxel converter.

It takes a spritesheet, extracts the data and creates a 3D representation. Animation is also possible.

I tweaked the algorithm a bit and used MultiMesh, dropping the draw call count to 1. But it surely can be optimised further.

I've included a simple demo scene. Because the sprite I used is not centered, the rotation will get weird if you change the X size of voxels.

The spritesheet must be imported as uncompressed (Lossless, VRAM Uncompressed etc.) in order to work.

Credits:
Warrior sprite by Clembod.

MIT license. Use it for whatever you want.
