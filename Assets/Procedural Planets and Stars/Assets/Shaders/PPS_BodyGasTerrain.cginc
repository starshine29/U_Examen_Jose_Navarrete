#include "PPS_BodyCG.cginc"
#include "UnityCG.cginc"

sampler2D _Gradient;
sampler2D _MainTex;
fixed _Distortion;

fixed _AnimationSpeed;

struct appdata
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 uv : TEXCOORD0;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	fixed4 color : COLOR;
	float4 uv : TEXCOORD0;
#ifdef _QUALITY_LOW
	float2 uv01 : TEXCOORD1;
#else
	float4 uv01 : TEXCOORD1;
#endif

	half4 worldNormal : TEXCOORD2; // worldNormal (.xyz), normal.y (.w)
	fixed4 lightDir : TEXCOORD3;

#ifdef _RIM_ON
	fixed2 NdotX : TEXCOORD4; // NdotV (.x), LdotV (.y)
#endif

#ifdef _QUALITY_HIGH
	float2 uv23 : TEXCOORD5;
#else 
	#ifdef _QUALITY_VERYHIGH
	float4 uv23 : TEXCOORD5;
	#endif
#endif

};

v2f vert(appdata v)
{
	v2f o;
	
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.color = tex2Dlod(_Gradient, fixed4(0.5,0.5,0,0));
	
	o.worldNormal.xyz = UnityObjectToWorldNormal(v.normal);
	float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.lightDir = GetLightDirection(worldPos);

	o.worldNormal.w = v.normal.y; // light amount
	o.worldNormal.w *= o.worldNormal.w;
	o.worldNormal.w *= o.worldNormal.w;
	o.worldNormal.w *= o.worldNormal.w;
	o.worldNormal.w *= o.worldNormal.w;
	o.worldNormal.w = 1 - o.worldNormal.w;

#ifdef _RIM_ON
	o.NdotX = VertexInnerRim(GetWorldViewDirection(worldPos), o.worldNormal.xyz, o.lightDir.xyz);	// rim
#endif
	
	o.uv = float4(v.uv.xy, v.uv.xy * 3);
	o.uv01.xy = v.uv;
#ifndef _QUALITY_LOW
	o.uv01.zw = v.uv * 3;
	#ifndef _QUALITY_MEDIUM	
	o.uv23.xy = v.uv * 4;
		#ifndef _QUALITY_HIGH
	o.uv23.zw = v.uv * 11;
		#endif
	#endif
#endif

#ifdef _ANIMATE_ON
	o.uv01.xy += (float2(_Time.x * 0.05, _Time.x * 0.05) * _AnimationSpeed) % 1;
	#ifndef _QUALITY_LOW
		o.uv01.zw += (float2(0, _Time.x * -0.25) * _AnimationSpeed) % 1;
		#ifndef _QUALITY_MEDIUM	
		o.uv23.xy += (float2(_Time.x, 0) * _AnimationSpeed) % 1;
			#ifndef _QUALITY_HIGH
		o.uv23.zw += (float2(_Time.x * 2, 0) * _AnimationSpeed) % 1;
			#endif
		#endif
	#endif
#endif

	return o;
}

fixed4 frag (v2f i) : SV_Target
{	
	fixed3 mainTex = tex2D(_MainTex, i.uv01.xy).rar;
	mainTex.g = mainTex.g * 2 - 1;

	mainTex.rb = tex2D(_MainTex, i.uv.xy).rg * 1.2;
	mainTex.rb *= tex2D(_MainTex, half2(0, i.uv.y + mainTex.g * 0.05 * _Distortion)).a * 1.5;

#ifndef _QUALITY_LOW
	mainTex.rb *= tex2D(_MainTex, i.uv01.zw + mainTex.g * 0.3 * _Distortion).rg * 0.5 + 0.75;
	#ifndef _QUALITY_MEDIUM
	mainTex.r += tex2D(_MainTex, i.uv.zw + tex2D(_MainTex, i.uv23.xy).a * 0.1).a * 0.25;
	mainTex.r /= 1.2;
		#ifndef _QUALITY_HIGH
	mainTex.r += tex2D(_MainTex, i.uv.zw * 4 + tex2D(_MainTex, i.uv23.zw).a * 0.1).a * 0.15;
	mainTex.r /= 1.15;
		#endif
	#endif
#endif
	mainTex.rb = saturate(mainTex.rb);
	
	fixed NdotL = saturate(dot(i.worldNormal.xyz, i.lightDir.xyz));

	fixed3 texGrad = tex2D(_Gradient, mainTex.rb);		
	texGrad = lerp(i.color, texGrad, i.worldNormal.w);
	texGrad *= saturate(NdotL - _AmbientLight) + _AmbientLight;
	
#ifdef _RIM_ON
	fixed rim = FragmentInnerRim(i.NdotX, NdotL);
	texGrad = lerp(texGrad, lerp(_RimColor, 1, rim * rim), rim);
#endif
	
	return fixed4(texGrad, 1.0);
}