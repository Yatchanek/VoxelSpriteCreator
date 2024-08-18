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

	vec3 position = texture(positions, vec2((INSTANCE_CUSTOM.r + 0.5) * x_p_pixel_size, (anim_frame + 0.5) * y_p_pixel_size)).rgb;
	vec4 color = texture(colors, vec2(INSTANCE_CUSTOM.r * x_pixel_size + 0.5 * x_pixel_size, (anim_frame + 0.5) * y_pixel_size));

	vec3 new_vertex = 
	vec3(- 0.5 * x_resolution + position.x * scale, 0.5 * y_resolution -position.y * scale, position.z * scale);
	
	VERTEX += new_vertex;
	VERTEX *= voxel_size;
	
	VERTEX *= color.a;
	COLOR = color;
}

void fragment() {
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	
	ALBEDO = COLOR.rgb * 5.0;
}
