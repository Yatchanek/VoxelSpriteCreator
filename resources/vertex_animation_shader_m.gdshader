shader_type spatial;
render_mode depth_draw_opaque, cull_back, shadows_disabled;

uniform sampler2D colors : source_color, filter_linear;
uniform sampler2D positions : filter_linear;

uniform vec3 voxel_size;
uniform float x_resolution;
uniform float y_resolution;

uniform float brightness : hint_range(-2.0, 2.0, 0.01) = 0.0;
uniform float contrast : hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float saturation : hint_range(-10.0, 10.0, 0.01) = 1.0;

uniform float anim_frame;

mat4 brightness_matrix(float b) {
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)
	);
}

mat4 contrast_matrix(float c) {
	float t = (1.0 - c) / 2.0;
	return mat4(
		vec4(c, 0, 0, 0),
		vec4(0, c, 0, 0),
		vec4(0, 0, c, 0),
		vec4(t, t, t, 1)
	);
}

mat4 saturation_matrix(float s) {
	vec3 luminance = vec3(0.3086, 0.6094, 0.0820);
	float sr = (1.0 - s) * luminance.r;
	float sg = (1.0 - s) * luminance.g;
	float sb = (1.0 - s) * luminance.b;
	
	return mat4(
		vec4(sr + s, sr, sr, 0),
		vec4(sg, sg + s, sg, 0),
		vec4(sb, sb, sb + s, 0),
		vec4(0, 0, 0, 1)
	);
}

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
	ROUGHNESS = 0.0;
	METALLIC = 0.0;
	vec4 color = COLOR;
	mat4 matrix = brightness_matrix(brightness) * contrast_matrix(contrast) * saturation_matrix(saturation);
	color = matrix * color;
	ALBEDO = color.rgb;
	EMISSION = ALBEDO * 0.75;
}
