shader_type spatial;
render_mode depth_prepass_alpha, blend_add;

void vertex() {
	COLOR = INSTANCE_CUSTOM;
	
}

void fragment() {
	ROUGHNESS = .95;
	METALLIC = .15;
	SPECULAR = .55;
	ALPHA = COLOR.a;
	ALBEDO = COLOR.rgb;
	
}