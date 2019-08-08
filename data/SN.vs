in vec3 uv_vertexAttrib;
in vec2 uv_texCoordAttrib0;
uniform mat4 uv_modelViewProjectionMatrix;

uniform float radMax;
uniform float timeMax;
uniform float timeMin;
uniform sampler2D stateTexture;

out vec2 texcoord; 
out vec3 position;
out float fTime;
out float fTime1;
void main()
{

	float eventTime = texture(stateTexture, vec2(0.5)).r;
	fTime = eventTime;
	fTime1 = clamp(1. - (timeMax - eventTime)/(timeMax - timeMin), 0, 1.);
	float rad = radMax*clamp(1. - (timeMax - eventTime)/(timeMax - timeMin), 0, 1.);

	texcoord = uv_texCoordAttrib0;
	position = uv_vertexAttrib;
    gl_Position = uv_modelViewProjectionMatrix * vec4( uv_vertexAttrib, 1.0/rad );;

}
