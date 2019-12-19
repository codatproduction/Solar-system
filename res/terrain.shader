shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float min_val = 1.0;
uniform float max_val = 1.05;

uniform vec4 low_color : hint_color = vec4(0.90, 0.93, 0.62, 1.0); 
uniform vec4 high_color : hint_color = vec4(0.56, 1.0, 0.53, 1.0);

varying flat vec3 out_color;

vec3 lerpColor(vec4 a, vec4 b, float t){
	float rr = a.r + (b.r - a.r) * t;
	float gg = a.g + (b.g - a.g) * t;
	float bb = a.b + (b.b - a.b) * t;
	return vec3(rr, gg, bb);
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	out_color = vec3(low_color.r, low_color.g, low_color.b);
	
	float l = length(VERTEX);

	if (l > min_val){
		out_color = lerpColor(low_color, high_color, clamp((l - min_val) / (max_val - min_val), 0.0, 1.0));
	}
		
	
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALBEDO = out_color * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = 1.0;
	SPECULAR = specular;
}
