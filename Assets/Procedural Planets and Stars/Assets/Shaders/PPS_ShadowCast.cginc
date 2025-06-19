#include "UnityCG.cginc"

struct VertexData
{
	float4 position : POSITION;
};

float4 vert(VertexData v) : SV_POSITION
{
	return UnityObjectToClipPos(v.position);
}

half4 frag() : SV_TARGET
{
	return 0;
}