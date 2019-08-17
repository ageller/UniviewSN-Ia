uniform float uv_fade;
uniform mat4 uv_modelViewInverseMatrix;

uniform sampler2D cmap;
uniform float SNAlpha;
uniform float SNFadeFac;

in vec2 texcoord;
in vec3 position;
in float lum;

out vec4 fragColor;

//from https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
//simple 3D noise
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}
float snoise(vec3 p){
	vec3 a = floor(p);
	vec3 d = p - a;
	d = d * d * (3.0 - 2.0 * d);

	vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
	vec4 k1 = perm(b.xyxy);
	vec4 k2 = perm(k1.xyxy + b.zzww);

	vec4 c = k2 + a.zzzz;
	vec4 k3 = perm(c);
	vec4 k4 = perm(c + 1.0);

	vec4 o1 = fract(k3 * (1.0 / 41.0));
	vec4 o2 = fract(k4 * (1.0 / 41.0));

	vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
	vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

	return o4.y * d.y + o4.x * (1.0 - d.y);
}

// from https://www.seedofandromeda.com/blogs/49-procedural-gas-giant-rendering-with-gpu-noise
//fractal noise
float noise(vec3 position, int octaves, float frequency, float persistence, int rigid) {
	float total = 0.0; // Total value so far
	float maxAmplitude = 0.0; // Accumulates highest theoretical amplitude
	float amplitude = 1.0;
	const int largeN = 50;
	for (int i = 0; i < largeN; i++) {
		if (i > octaves){
				break;
		}
		// Get the noise sample
		if (rigid == 0){
		   total += snoise(position * frequency) * amplitude;
		} else {
		// rigid noise
			total += ((1.0 - abs(snoise(position * frequency))) * 2.0 - 1.0) * amplitude;
		}
		// Make the wavelength twice as small
		frequency *= 2.0;
		// Add to our maximum possible amplitude
		maxAmplitude += amplitude;
		// Reduce amplitude according to persistence for the next octave
		amplitude *= persistence;
	}

	// Scale the result by the maximum amplitude
	return total / maxAmplitude;
}


void main()
{

	//fade factor (the luminosity peaks at about 0.1)
	float SNfade = clamp(pow(lum*10,2.),0,0.9);
	
	//noise
	vec3 pNorm = 5.*position.xyz;//vec3(texcoord, noiseTime);

	//fractal noise (can play with these)
	float n1 = noise(pNorm, 3, 3., 0.5, 1); 

	// spots
	float s = 0.01; //smaller number means larger spots?
	float frequency = 3;//
	float threshold = 0.;// limit number of spots
	float t1 = snoise(pNorm * frequency) - s;
	float t2 = snoise((pNorm + 30.) * frequency) - s;
	float ss = (max(t1 * t2, threshold) - threshold) ;

	// Accumulate total noise
	float n = clamp(n1 - ss + 0.7, 0, 1);
	fragColor = vec4(texture(cmap ,vec2(clamp(n,0.1,1),0.5)).rgb, 1.);
	fragColor.a = n*uv_fade*SNAlpha*SNfade;
	
	//fragColor = vec4(cm,1);

}
