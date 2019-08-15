in vec3 uv_vertexAttrib;
in vec2 uv_texCoordAttrib0;
uniform mat4 uv_modelViewProjectionMatrix;

uniform float radScale;

uniform sampler2D stateTexture;

out vec2 texcoord; 
out vec3 position;
out float rad;

// Equation 7 from [this paper](https://arxiv.org/abs/1612.02097)
float SNIaLum(float t, float A, float t0, float tb, float a1, float a2, float s)
{
	float ar = 2.*(a1 + 1.);
	float ad = a1 - a2;
	float tfac = (t - t0)/tb;
	return A * tfac**ar * (1. + tfac**(s*ad))**(-2./s);
}

void main()
{

	float eventTime = texture(stateTexture, vec2(0.5)).r;

	//these values fit the data relatively well (see my notebook in rawdata)
	float lum = SNIaLum(eventTime, 1., -2., 13., 0.1, -2.2, 0.6);
	float rad = radScale*lum;

	texcoord = uv_texCoordAttrib0;
	position = uv_vertexAttrib;
    gl_Position = uv_modelViewProjectionMatrix * vec4( uv_vertexAttrib, 1.0/rad );;

}
