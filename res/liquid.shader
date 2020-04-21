shader_type spatial;

uniform float beer_factor : hint_range(0.0, 20.0) = 0.1;
uniform vec4 out_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float explosiveness : hint_range(0.001, 1.0) = 0.2;
uniform float emission_energy : hint_range(0, 2.0) = 1.0;


float generateOffset(float x, float y, float z, float val1, float val2, float time){
	float speed = 1.0;
	
	float radiansX = ((mod(x + z * x * val1, explosiveness) / explosiveness) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansY = ((mod(val2 * (z * x + x * z + y * x + y * z), explosiveness) / explosiveness) + (time * speed) * 2.0 * mod(x,2.0)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), explosiveness) / explosiveness) + (time * speed) * 2.0 * mod(x,2.0)) * 2.0 * 3.14;

	return explosiveness * 0.5 * (sin(radiansZ) + cos(radiansX) + cos(radiansY));
}

vec3 applyDistortion(vec3 vertex, float time){
	float xd = generateOffset(vertex.x, vertex.y, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.y, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.y, vertex.z, 0.15, 0.2, time);
	return vertex + vec3(xd, yd, zd);
}

void vertex(){
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment(){
	
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	
	ALBEDO = out_color.xyz;
	METALLIC = 0.6;
	SPECULAR = 0.5;
	ROUGHNESS = 0.2;
	
	EMISSION = out_color.rgb * emission_energy;
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	
	depth = exp(-depth * beer_factor);
	ALPHA = clamp(1.0 - depth, 0.0, 1.0);
	//ALPHA = 0.5;
	

}






