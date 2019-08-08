uniform float uv_fade;
uniform float alpha;
uniform sampler2D cmap;

in float noise;
in vec3 texcoord;

out vec4 fragColor;

//https://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js/
//https://shaderfrog.com/app/editor

float random( vec3 scale, float seed ){
	return fract( sin( dot( texcoord + seed, scale ) ) * 43758.5453 + seed ) ;
}

void main() {

	// get a random offset
	float r = .01 * random( vec3( 12.9898, 78.233, 151.7182 ), 0.0 );
	vec2 tPos = vec2(1.3 * noise + r, 0 );
	vec4 color = texture2D( cmap, tPos );

	fragColor = vec4( color.rgb, alpha*uv_fade );


}
