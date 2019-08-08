uniform float uv_fade;
uniform float alpha;
uniform sampler2D cmap;
uniform float noiseDisplacementHeight;

in float noise;
in float displacement;
in vec3 texcoord;

out vec4 fragColor;

//https://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js/
//https://shaderfrog.com/app/view/30

float random( vec3 scale, float seed ){
	return fract( sin( dot( texcoord + seed, scale ) ) * 43758.5453 + seed ) ;
}

void main() {

	// get a random offset
	float r = .001 * random( vec3( 12.9898, 78.233, 151.7182 ), 0.0 );
	float d = -displacement/noiseDisplacementHeight;
	vec2 tPos = vec2(clamp(1. - 0.9*d - r,0,0.99), 0.5);
	//vec2 tPos = vec2(clamp(noise - r,0,0.99), 0.5);
	vec4 color = texture2D( cmap, tPos );
	
	fragColor = vec4( color.rgb, alpha*uv_fade*pow(1. - d, 10) );
	//fragColor = vec4( vec3(noise, -1.*displacement,0), alpha*uv_fade );


}
