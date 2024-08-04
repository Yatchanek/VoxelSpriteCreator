shader_type spatial;
render_mode depth_prepass_alpha, blend_mix;

uniform float brightness : hint_range(-1, 1) = 0.0	;
uniform float contrast : hint_range(0, 3) = 1.4;
uniform float saturation : hint_range(0, 3) = 1.15;

uniform float redVal : hint_range(0, 1) = 1.0;
uniform float greenVal : hint_range(0, 1) = 1.0;
uniform float blueVal : hint_range(0, 1) = 1.0;

mat4 contrastMatrix( float _contrast ){
	float t = ( 1.0 - _contrast ) / 2.0;
    return mat4( 
		vec4(_contrast, 0, 0, 0),
		vec4(0, _contrast, 0, 0),
		vec4(0, 0, _contrast, 0),
		vec4(t, t, t, 1));
}
//---------------------------------------------
//BRIGHTNESS
//---------------------------------------------
mat4 brightnessMatrix( float _brightness ){
    return mat4( vec4(1, 0, 0, 0),
                 vec4(0, 1, 0, 0),
                 vec4(0, 0, 1, 0),
                 vec4(_brightness, _brightness, _brightness, 1));
}

mat4 saturationMatrix( float _saturation ){
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - _saturation;
	
    vec3 red = vec3( luminance.x * oneMinusSat );
    red+= vec3(_saturation, 0, 0)* redVal;
    vec3 green = vec3( luminance.y * oneMinusSat );
    green += vec3( 0,_saturation, 0 )* greenVal;
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue += vec3( 0, 0,_saturation )* blueVal;
	
    return mat4(vec4(red, 0),vec4(green,0),vec4(blue,0),vec4(0, 0, 0, 1));
}

void vertex() {
	COLOR = brightnessMatrix(brightness) * contrastMatrix(contrast) * saturationMatrix(saturation) * INSTANCE_CUSTOM;
	
}

void fragment() {
	ROUGHNESS = 1.0;
	METALLIC = .0;
	SPECULAR = .0;
	ALPHA = COLOR.a;
	ALBEDO = COLOR.rgb;
	EMISSION = ALBEDO * 0.05;
}