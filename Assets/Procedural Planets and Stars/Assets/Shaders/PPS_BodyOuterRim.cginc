#include "PPS_BodyCG.cginc"
#include "UnityCG.cginc"

fixed4 _RimColor;
float _RimRadius;
fixed _RimOpacity;

half _LiquidHeight;

struct appdata
{
	half4 vertex : POSITION;
	half3 normal : NORMAL;
};

struct v2f
{
	half4 vertex : SV_POSITION;
	#ifdef _CAMERA_PERSPECTIVE
		float rimPos : TEXCOORD0;
	#else
		#ifdef _QUALITYLIGHTING_ON
			float1 R : TEXCOORD0;
			float3 worldPos : TEXCOORD3;
		#else
			float2 R : TEXCOORD0;
		#endif
	#endif
	#ifdef _QUALITYLIGHTING_ON
		fixed4 XdotL : TEXCOORD1; // VdotL (.x), lightDir (.yzw)
		half3 worldNormal : TEXCOORD2;
	#else
		fixed2 XdotL : TEXCOORD1; // VdotL (.x), NdotL (.y)
	#endif
};

v2f vert(appdata v)
{
	v2f o;

	float3 worldPos;
	#ifdef _CAMERA_ORTHOGRAPHIC
		float3 objCenterViewPos = UnityObjectToViewPos(fixed4(0,0,0,1));
		worldPos = UnityObjectToViewPos(v.vertex) - objCenterViewPos;
		o.R.r = worldPos.x * worldPos.x + worldPos.y * worldPos.y + worldPos.z * worldPos.z;
	#endif

	v.vertex.xyz *= 1 + _RimRadius;
	o.vertex = UnityObjectToClipPos(v.vertex);

	worldPos = mul(unity_ObjectToWorld, v.vertex);
	float3 worldCenter = mul(unity_ObjectToWorld, fixed4(0,0,0,1));
	fixed3 viewDir = GetWorldViewDirection(worldPos);
	fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
	fixed3 lightDir = GetLightDirection(worldPos);

	o.XdotL.x = saturate(dot(lightDir.xyz, -viewDir));
	o.XdotL.x *= o.XdotL.x;
	o.XdotL.x *= o.XdotL.x;
	o.XdotL.x *= o.XdotL.x;
	o.XdotL.x *= o.XdotL.x;
	
	#ifdef _CAMERA_PERSPECTIVE
		float3 rimPos = worldCenter - _WorldSpaceCameraPos;
		o.rimPos = dot(rimPos, viewDir);
		rimPos = viewDir * o.rimPos * sign(-o.rimPos) - rimPos;
		rimPos = mul(unity_WorldToObject, rimPos);
		o.rimPos = dot(rimPos, rimPos);
	#else
		#ifdef _QUALITYLIGHTING_ON
			o.worldPos = UnityObjectToViewPos(v.vertex) - objCenterViewPos; // local-ish Position
		#else
			worldPos = UnityObjectToViewPos(v.vertex) - objCenterViewPos; // local-ish Position
			o.R.g = worldPos.x * worldPos.x + worldPos.y * worldPos.y;
		#endif
	#endif
	
	lightDir = normalize(lightDir.xyz - viewDir * 0.9);

	#ifdef _QUALITYLIGHTING_ON
		o.XdotL.yzw = lightDir;
		o.worldNormal = worldNormal;
	#else
		o.XdotL.y = saturate(dot(lightDir.xyz, worldNormal));
	#endif

	return o;
}

fixed4 frag(v2f i) : COLOR
{
	#ifdef _CAMERA_PERSPECTIVE
		fixed rim = sqrt(i.rimPos);
		rim = saturate(1 - abs(1-rim) / _RimRadius);
	#else
		#ifdef _QUALITYLIGHTING_ON
			fixed rim = saturate(1 - abs((i.worldPos.x * i.worldPos.x + i.worldPos.y * i.worldPos.y) - i.R.r) / (i.R.r * _RimRadius * 2));
		#else
			fixed rim = saturate(1 - abs(i.R.g - i.R.r) / (i.R.r * _RimRadius * 2));
		#endif
	#endif
	
	rim *= (1 + i.XdotL.x);

	#ifdef _QUALITYLIGHTING_ON
		rim *= pow(saturate(dot(i.XdotL.yzw, i.worldNormal)), 0.333);
	#else
		rim *= pow(i.XdotL.y, 0.333);
	#endif
	
	fixed rim2 = rim * rim;
	rim2 *= rim2;

#ifdef _GASRIM_ON
	return _RimColor * rim * _RimOpacity;
#else
	return lerp(_RimColor, 1, rim2) * rim * _RimOpacity;
#endif
}