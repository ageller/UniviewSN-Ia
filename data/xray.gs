layout(triangles) in;
layout(line_strip, max_vertices=3) out;

uniform mat4 uv_modelViewProjectionMatrix;
uniform mat4 uv_modelViewProjectionInverseMatrix;

uniform sampler2D stateTexture;

//uniform float eventTime;
uniform float neutrinoRadMax;
uniform float neutrinoTimeMax;
uniform float neutrinoLength;

out vec2 texcoord;


void main()
{
	float eventTime = texture(stateTexture, vec2(0.5)).r;	
	
	//simple explosion
	float rad = neutrinoRadMax*(1. - (neutrinoTimeMax - eventTime)/neutrinoTimeMax);
	float  j = 0;

	vec3 vertexPos = gl_in[0].gl_Position.xyz;

	gl_Position =  uv_modelViewProjectionMatrix *vec4(vertexPos, 1./rad);
	texcoord = vec2(0, 0);
	EmitVertex();

	gl_Position =  uv_modelViewProjectionMatrix *vec4(vertexPos, 1./(neutrinoLength*rad));
	texcoord = vec2(0, 1);
	EmitVertex();

	EndPrimitive();

}

