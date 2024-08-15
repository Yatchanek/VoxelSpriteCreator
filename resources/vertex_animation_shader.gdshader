shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D colors : source_color, filter_linear;
uniform sampler2D positions : filter_linear;

uniform vec3 voxel_size;
uniform float x_resolution;
uniform float y_resolution;

uniform float anim_frame;

void vertex() {
	ivec2 tex_size = textureSize(colors, 0);
	ivec2 pos_size = textureSize(positions, 0);
	float x_pixel_size = 1.0 / float(tex_size.x);
	float y_pixel_size = 1.0 / float(tex_size.y);
	float x_p_pixel_size = 1.0 / float(pos_size.x);
	float y_p_pixel_size = 1.0 / float(pos_size.y);

	float scale = 255.0;

	vec3 position = texture(positions, vec2((UV.x + 0.5) * x_p_pixel_size, (anim_frame + 0.5) * y_p_pixel_size)).rgb;
	vec4 color = texture(colors, vec2(UV.x * x_pixel_size + 0.5 * x_pixel_size, (anim_frame + 0.5) * y_pixel_size));

	vec3 new_vertex = 
	vec3(-0.5 * x_resolution * voxel_size.x + position.x * voxel_size.x * scale, 0.5 * y_resolution * voxel_size.y - position.y * voxel_size.y * scale, 0.5 * voxel_size.z + position.z * voxel_size.z * scale
	);
	
	
	VERTEX += new_vertex;
	VERTEX *= color.a;
	COLOR = color;
}

void fragment() {
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	
	ALBEDO = COLOR.rgb * 5.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
