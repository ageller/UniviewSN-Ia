in vec3 uv_vertexAttrib;
in vec3 uv_normalAttrib;
in vec2 uv_texCoordAttrib0;
uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewMatrix;

uniform float radMax;
uniform float timeMax;
uniform float timeMin;
uniform sampler2D stateTexture;

uniform float noisePulseHeight;
uniform float noiseSpeed;
uniform float noiseDisplacementHeight;
uniform float noiseTurbulenceDetail;

out float noise;
out float displacement;
out vec3 texcoord;

const float PI = 3.141592653589793;

// axis should be normalized
mat3 rotationMatrix(vec3 axis, float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	
	return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
				oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
				oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}


//https://www.clicktorelease.com/blog/vertex-displacement-noise-3d-webgl-glsl-three-js/
//https://shaderfrog.com/app/view/30

vec3 mod289(vec3 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x) {return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 permute(vec4 x) {return mod289(((x*34.0)+1.0)*x);}
vec4 taylorInvSqrt(vec4 r) {return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

// Klassisk Perlin noise 
float cnoise(vec3 P) {
	vec3 Pi0 = floor(P); // indexing
	vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	vec3 Pf0 = fract(P); // Fractional part for interpolation
	vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
	vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	vec4 iy = vec4(Pi0.yy, Pi1.yy);
	vec4 iz0 = Pi0.zzzz;
	vec4 iz1 = Pi1.zzzz;

	vec4 ixy = permute(permute(ix) + iy);
	vec4 ixy0 = permute(ixy + iz0);
	vec4 ixy1 = permute(ixy + iz1);

	vec4 gx0 = ixy0 * (1.0 / 7.0);
	vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
	gx0 = fract(gx0);
	vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
	vec4 sz0 = step(gz0, vec4(0.0));
	gx0 -= sz0 * (step(0.0, gx0) - 0.5);
	gy0 -= sz0 * (step(0.0, gy0) - 0.5);

	vec4 gx1 = ixy1 * (1.0 / 7.0);
	vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
	gx1 = fract(gx1);
	vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
	vec4 sz1 = step(gz1, vec4(0.0));
	gx1 -= sz1 * (step(0.0, gx1) - 0.5);
	gy1 -= sz1 * (step(0.0, gy1) - 0.5);

	vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
	vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
	vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
	vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
	vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
	vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
	vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
	vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

	vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;

	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
	float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
	float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
	float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
	float n111 = dot(g111, Pf1);

	vec3 fade_xyz = fade(Pf0);
	vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
	vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
	return 2.2 * n_xyz;
}

// Ashima code 
float turbulence( vec3 p ) {
	float t = -0.5;
	for (float f = 1.0 ; f <= 10.0 ; f++ ){
		float power = pow( 2.0, f );
		t += abs( cnoise( vec3( power * p ) ) / power );
	}
	return t;
}


void main()
{  
	
	float eventTime = texture(stateTexture, vec2(0.5)).r;
	float rad = radMax*clamp(1. - (timeMax - eventTime)/(timeMax - timeMin), 0, 1.);

	// get a random offset for rotation
	float rX = turbulence( vec3( timeMin/10., 11., 111. ))*2.*PI;
	float rY = turbulence( vec3( timeMin/10., 22., 222. ))*2.*PI;
	float rZ = turbulence( vec3( timeMin/10., 33., 333. ))*2.*PI;
	mat3 rotX = rotationMatrix(vec3(1,0,0), rX); 
	mat3 rotY = rotationMatrix(vec3(0,1,0), rY); 
	mat3 rotZ = rotationMatrix(vec3(0,0,1), rZ); 
	
	
	// add time to the noise parameters so it's animated
	//low frequency as a base (and offset?)
    float n1 = -1.*turbulence( 0.1*uv_normalAttrib + timeMin/5.);
	//additional user defined noise on top
    float n2 = -0.8*turbulence( noiseTurbulenceDetail*uv_normalAttrib + ( (eventTime - timeMin)*noiseSpeed ) );
    noise = n1 + n2;
	
	//pules?
    float b = noisePulseHeight*cnoise( 0.05*uv_vertexAttrib + vec3((eventTime - timeMin)*noiseSpeed ) );
	
	//final displacement
    displacement = ( 0.0 - noiseDisplacementHeight )*noise + b;
	
	vec3 newPosition = uv_vertexAttrib + uv_normalAttrib * displacement;
	gl_Position = uv_modelViewProjectionMatrix * vec4( rotX*rotY*rotZ*newPosition, 1.0/rad );

	//this seems to work as expected for x and y, but z seems to have some offset that I don't understand
	//and all I really care about is the z dimension!
	vec4 foo =  uv_modelViewMatrix * vec4(  rotX*rotY*rotZ*uv_vertexAttrib, 1.0 );
	texcoord = foo.xyz;

}