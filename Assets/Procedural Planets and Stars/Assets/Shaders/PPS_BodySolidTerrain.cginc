#include "PPS_BodyCG.cginc"
#include "UnityCG.cginc"

#ifndef _QUALITY_LOW
	float _TexLOD;
#endif

sampler2D _Gradient;
sampler2D _MainTex, _PlainTex;
sampler2D _MasksTex; // 2D color mask

fixed _BumpScale;

fixed _TerraformMask, _TerraformFunction;
half _TerrainHeight;
fixed _LiquidHeight;
fixed _MountainIce;

sampler2D _IceGradient;
fixed _PolarIce;

sampler2D _LiquidGradient;
float _LiquidCoastReach;
fixed4 _LiquidEmissionColor;
fixed _LiquidEmission;
float _SpecularHighlight;
fixed4 _SpecularColor;

// lights
sampler2D _LightsTex;
fixed4 _LightsColor;
fixed _LightsHeightMask;

#ifdef _CLOUDS_ON
	sampler2D _CloudsTex, _CloudsPolarTex;
	float _CloudsUVTile;
	fixed4 _CloudsColor1, _CloudsColor2;
	fixed _CloudsVolume, _CloudsOpacity;
	#ifdef _ANIMATE_ON
		fixed _AnimationSpeed;
	#endif
#endif

// static
static const float PlanarBlend = 20;

struct appdata
{
	float4 vertex : POSITION;
	float4 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 uv : TEXCOORD0;
};

struct v2f
{
	float4 vertex : SV_POSITION;
	float4 uvTop0 : TEXCOORD0;
	#if defined(_QUALITY_HIGH) || defined(_QUALITY_VERYHIGH)
		float4 uv12 : TEXCOORD1;
	#else
		float2 uv12 : TEXCOORD1;
	#endif
	fixed4 lightDir : TEXCOORD2;
	#ifdef _RIM_ON
		#ifdef _QUALITYLIGHTING_ON
			fixed3 NdotX : TEXCOORD3; // normal.y (.x), NdotV (.y), LdotV (.z)
		#else
			fixed4 NdotX : TEXCOORD3; // normal.y (.x), NdotV (.y), LdotV (.z), specular highlight (.w)
		#endif
	#else
		#ifdef _QUALITYLIGHTING_ON
			fixed NdotX : TEXCOORD3; // normal.y (.x)
		#else
			fixed2 NdotX : TEXCOORD3; // normal.y (.x), specular highlight (.y)
		#endif
	#endif
	half4 tspace0 : TEXCOORD4; // worldTangent.x, worldBitangent.x, worldNormal.x, 0
	half4 tspace1 : TEXCOORD5; // worldTangent.y, worldBitangent.y, worldNormal.y, normal.y // for poles
	half4 tspace2 : TEXCOORD6; // worldTangent.z, worldBitangent.z, worldNormal.z, 0
	#ifdef _CLOUDS_ON
		float4 uvC : TEXCOORD7;
	#endif
};

v2f vert(appdata v)
{
	v2f o;
	
	o.vertex = UnityObjectToClipPos(v.vertex);
	
	half3 worldNormal = UnityObjectToWorldNormal(v.normal);
	half3 worldTangent = UnityObjectToWorldDir(v.tangent);
	half3 worldBitangent = cross(worldNormal, worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
	float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.lightDir = GetLightDirection(worldPos);
	fixed3 worldViewDir = GetWorldViewDirection(worldPos);
	o.tspace0 = half4(worldTangent.x, worldBitangent.x, worldNormal.x, worldViewDir.x);
	o.tspace1 = half4(worldTangent.y, worldBitangent.y, worldNormal.y, worldViewDir.y);
	o.tspace2 = half4(worldTangent.z, worldBitangent.z, worldNormal.z, worldViewDir.z);

	// specular
	o.NdotX.x = v.normal.y;
	#ifdef _RIM_ON
		o.NdotX.yz = VertexInnerRim(worldViewDir, worldNormal, o.lightDir.xyz);	// rim
		#ifndef _QUALITYLIGHTING_ON
			o.NdotX.w = saturate(dot(reflect(-o.lightDir.xyz, worldNormal * 0.9), worldViewDir));
			o.NdotX.w = pow(o.NdotX.w, _SpecularHighlight);
		#endif
	#else
		#ifndef _QUALITYLIGHTING_ON
			o.NdotX.y = saturate(dot(reflect(-o.lightDir.xyz, worldNormal * 0.9), worldViewDir));
			o.NdotX.y = pow(o.NdotX.y, _SpecularHighlight);
		#endif
	#endif

	o.uvTop0.xy = (v.vertex.xyz * 0.5 + 0.5).zx;
	
	o.uvTop0.zw = v.uv;
	o.uv12.xy = v.uv * 3;
	#if defined(_QUALITY_HIGH) || defined(_QUALITY_VERYHIGH)
		o.uv12.zw = v.uv * 7;
	#endif
	
	#ifdef _CLOUDS_ON
		o.uvC.xy = (v.vertex.xyz * 0.5 * _CloudsUVTile + 0.5).zx;
		#ifdef _ANIMATE_ON
			float cosX = _AnimationSpeed * _Time.x;
			float sinX = sin(cosX);
			cosX = cos(cosX);
			o.uvC.xy = mul(o.uvC.xy - 0.5, float2x2(cosX, -sinX, sinX, cosX));
			o.uvC.xy += 0.5;

			o.uvC.zw = (v.uv.xy + float2(_Time.x, 0) * _AnimationSpeed * 0.2) * _CloudsUVTile;
		#else
			o.uvC.zw = v.uv.xy * _CloudsUVTile;
		#endif

	#endif

	return o;
}

fixed4 frag (v2f i) : SV_Target
{
	/// TEXTURES
	#ifdef _QUALITY_LOW
		fixed4 texDiff = tex2D(_MainTex, i.uvTop0.zw);
		#ifdef _FIXPOLES_ON
			fixed3 poles = tex2D(_MainTex, i.uvTop0.xy);
		#endif
		_BumpScale *= 0.25;
	#endif

	#ifdef _QUALITY_MEDIUM
		fixed4 texDiff = tex2Dlod(_MainTex, fixed4(i.uvTop0.zw, 0, min(_TexLOD, 2)));
		texDiff.rg *= 0.5;
		
		fixed3 poles = tex2D(_MainTex, i.uv12.xy);
		texDiff.rg += poles.rg * 0.6;
		texDiff.b *= poles.b * 0.666 + 0.666;

		texDiff.rg = saturate(texDiff.rg * 0.909);
		texDiff.b = saturate(texDiff.b);
		
		#ifdef _FIXPOLES_ON
			poles = tex2Dlod(_MainTex,fixed4(i.uvTop0.xy, 0, min(_TexLOD, 2)));
			poles.rg *= 0.5;

			fixed4 poles2 = tex2D(_MainTex, i.uvTop0.xy * 3);
			poles.rg += poles2.rg * 0.6;
			poles.b *= poles2.b * 0.666 + 0.666;

			poles.rg = saturate(poles.rg * 0.909);
			poles.b = saturate(poles.b);
		#endif
		_BumpScale *= 0.5;
	#endif

	#ifdef _QUALITY_HIGH
		fixed4 texDiff = tex2Dlod(_PlainTex, fixed4(i.uvTop0.zw, 0, min(_TexLOD, 2)));
		texDiff.rg *= 0.5;

		fixed3 poles = tex2Dlod(_MainTex, fixed4(i.uv12.xy, 0, max(_TexLOD - 2, 0)));
		texDiff.rg += poles.rg * 0.6;
		texDiff.b *= poles.b * 0.666 + 0.666;

		poles = tex2D(_MainTex, i.uv12.zw);
		texDiff.rg += poles.rg * 0.7;
		texDiff.b *= poles.b * 0.333 + 0.75;
		
		texDiff.rg = saturate(texDiff.rg * 0.55555);
		texDiff.b = saturate(texDiff.b);
		
		#ifdef _FIXPOLES_ON
			poles = tex2Dlod(_MainTex,fixed4(i.uvTop0.xy, 0, min(_TexLOD, 2)));
			poles.rg *= 0.5;

			fixed4 poles2 = tex2D(_MainTex, i.uvTop0.xy * 3);
			poles.rg += poles2.rg * 0.6;
			poles.b *= poles2.b * 0.666 + 0.666;

			poles.rg = saturate(poles.rg * 0.909);
			poles.b = saturate(poles.b);
		#endif
		_BumpScale *= 0.75;
	#endif

	#ifdef _QUALITY_VERYHIGH
		fixed4 texDiff = tex2Dlod(_PlainTex, fixed4(i.uvTop0.zw, 0, min(_TexLOD, 2)));
		texDiff.rg *= 0.5;

		fixed3 poles = tex2Dlod(_MainTex, fixed4(i.uv12.xy, 0, max(_TexLOD - 2, 0)));
		texDiff.rg += poles.rg * 0.6;
		texDiff.b *= poles.b * 0.666 + 0.666;

		poles = tex2D(_MainTex, i.uv12.zw);
		texDiff.rg += poles.rg * 0.7;
		texDiff.b *= poles.b * 0.333 + 0.75;

		poles = tex2D(_MainTex, i.uv12.zw * 2);
		texDiff.rg += poles.rg * 0.5;
		texDiff.b *= poles.b * 0.05 + 0.95;
		
		texDiff.rg = saturate(texDiff.rg * 0.43478);
		texDiff.b = saturate(texDiff.b);
		
		#ifdef _FIXPOLES_ON
			poles = tex2Dlod(_MainTex,fixed4(i.uvTop0.xy, 0, min(_TexLOD, 2)));
			poles.rg *= 0.5;

			fixed4 poles2 = tex2D(_MainTex, fixed4(i.uvTop0.xy * 3, 0, max(_TexLOD - 2, 0)));
			poles.rg += poles2.rg * 0.6;
			poles.b *= poles2.b * 0.666 + 0.666;
			
			poles2 = tex2D(_MainTex, i.uvTop0.xy * 7);
			poles.rg += poles2.rg * 0.7;
			poles.b *= poles2.b * 0.333 + 0.75;
			
			poles2 = tex2D(_MainTex, i.uvTop0.xy * 9);
			poles.rg += poles2.rg * 0.5;
			poles.b *= poles2.b * 0.05 + 0.95;

			poles.rg = saturate(poles.rg * 0.43478);
			poles.b = saturate(poles.b);
		#endif
	#endif
	
	/// MASKS
	fixed3 masks = tex2D(_MasksTex, i.uvTop0.zw);

	i.NdotX.x = abs(i.NdotX.x); // se 2x rab
	#ifdef _FIXPOLES_ON
		fixed2 masksPolar = tex2D(_MasksTex, i.uvTop0.xy);

		fixed blendWeights = saturate(i.NdotX.x + 0.1 * poles.b * poles.b * poles.b);
		blendWeights = pow(blendWeights, PlanarBlend);
		masks.rg = lerp(masks.rg, masksPolar.rg, blendWeights);

		texDiff.xyz = lerp(texDiff.xyz, poles, blendWeights);
	#endif

	texDiff.rg = texDiff.rg * 2 - 1; // LIGHTING
	fixed terrainHeight = texDiff.b;
	
	fixed terrainHeightWithWater = (terrainHeight - _LiquidHeight * 0.9) / (lerp(1.0001, 2 * terrainHeight, _LiquidHeight * 0.333) - _LiquidHeight);
	fixed liquidDepth = saturate(_LiquidHeight - terrainHeight) / max(_LiquidHeight, 0.01);
	liquidDepth = liquidDepth * liquidDepth;
	
	/// ICE
	fixed iceThresh = (i.NdotX.x - 1) / _PolarIce + 1;
	iceThresh += lerp((terrainHeight - _LiquidHeight) * 3, terrainHeight, _PolarIce * _PolarIce);
	iceThresh = max(iceThresh, terrainHeight - (1 - _MountainIce));
	iceThresh = saturate(15 * iceThresh);

	/// LIGHTING with normal map (terrain)
	texDiff.z = pow(1 - saturate(dot(texDiff.xy, texDiff.xy)), _BumpScale * 5);
	texDiff.xy *= _BumpScale;
	half3 worldNormal = half3(
		dot(i.tspace0.xyz, texDiff.xyz),
		dot(i.tspace1.xyz, texDiff.xyz),
		dot(i.tspace2.xyz, texDiff.xyz)
	);
	
	fixed4 NdotL = fixed4(saturate(dot(worldNormal, i.lightDir.xyz)), 0, saturate(dot(half3(i.tspace0.z, i.tspace1.z, i.tspace2.z), i.lightDir.xyz)), 0);
	NdotL.y = saturate(NdotL.x - _AmbientLight) + _AmbientLight;
	NdotL.w = saturate(NdotL.z - _AmbientLight) + _AmbientLight;

	/// COLORING
	masks.rg = lerp(masks.rg, 1 - terrainHeight + _TerraformFunction, _TerraformMask);
	fixed3 texGrad = tex2D(_Gradient, fixed2(pow(terrainHeightWithWater, 1/_TerrainHeight), masks.r));
	fixed3 iceColor = tex2D(_IceGradient, fixed2(terrainHeightWithWater, masks.r));
	fixed3 iceColor2 = tex2D(_IceGradient, fixed2(0, masks.r));

	/// LIQUID
	fixed liquidThresh = terrainHeight - _LiquidHeight;
	fixed liquidMask = saturate(-liquidThresh  * abs(liquidThresh) * _LiquidCoastReach);
	texGrad = lerp(texGrad, iceColor * (1 - terrainHeightWithWater * 0.1), iceThresh);
	texGrad *= (1-liquidMask);
	
	fixed3 liquidTex = tex2D(_LiquidGradient, fixed2((1-liquidDepth), masks.g));
	liquidTex = lerp(liquidTex, lerp(iceColor2, liquidTex, liquidDepth), iceThresh);

	// SPECULAR AND NdotL
	#ifdef _QUALITYLIGHTING_ON
		fixed specular = saturate(dot(reflect(-i.lightDir.xyz, half3(i.tspace0.z, i.tspace1.z, i.tspace2.z) * 0.9), half3(i.tspace0.w, i.tspace1.w, i.tspace2.w)));
		specular = pow(specular, _SpecularHighlight);
		liquidTex = lerp(liquidTex, _SpecularColor * (1 - iceThresh * 0.375), specular);
	#else
		#ifdef _RIM_ON
			liquidTex = lerp(liquidTex, _SpecularColor * (1 - iceThresh * 0.375), i.NdotX.w);
		#else
			liquidTex = lerp(liquidTex, _SpecularColor * (1 - iceThresh * 0.375), i.NdotX.y);
		#endif
	#endif
	
	// liquidTex += lerp(i.NdotX.x * (1 - iceThresh * 0.375), 0, 0);
	liquidTex *= lerp(_LiquidEmission * lerp(1, 0.333, iceThresh), 1, NdotL.w);
	liquidTex *= liquidMask;
	
	fixed3 emission = _LiquidEmissionColor * _LiquidEmission;
	emission *= liquidMask;

	/// CITY LIGHTS
	fixed lights = 1-NdotL.z;
	lights *= lights;
	lights *= lights;
	lights *= lights;
	lights *= lights;

	lights *= tex2D(_LightsTex, i.uv12.xy).r * masks.b;
	lights *= (1-liquidMask);
	lights *= saturate((_LightsHeightMask - terrainHeight) * 10);
	// lights *= saturate(1 - iceThresh); // not on ice

	emission += lights * _LightsColor;
	texGrad *= NdotL.y;

	texGrad += liquidTex;
	texGrad += emission;

	/// CLOUDS
	#ifdef _CLOUDS_ON
		fixed cloudsNdotL = pow(saturate(dot(half3(i.tspace0.z, i.tspace1.z, i.tspace2.z) * 2, i.lightDir.xyz)), 0.75) * i.lightDir.w;
		fixed4 cloudsTex = tex2D(_CloudsTex, i.uvC.zw);

		#ifdef _FIXPOLES_ON
			cloudsTex = lerp(cloudsTex, tex2D(_CloudsPolarTex, i.uvC.xy), blendWeights);
		#endif

		fixed cloudHeight = saturate(cloudsTex.b + 0.2 * _CloudsVolume * cloudsTex.b);
		fixed cloudHeight2 = saturate(cloudsTex.a + 0.2 * _CloudsVolume * cloudsTex.a);

		cloudsTex.rg = cloudsTex.rg * 2 - 1; // LIGHTING
		cloudsTex.z = pow(1 - saturate(dot(cloudsTex.xy, cloudsTex.xy)), _BumpScale * 5);
		cloudsTex.xy *= _BumpScale;
		
		worldNormal = half3(
			dot(i.tspace0.xyz, cloudsTex.xyz),
			dot(i.tspace1.xyz, cloudsTex.xyz),
			dot(i.tspace2.xyz, cloudsTex.xyz)
		);

		cloudHeight *= saturate((cloudHeight - (1-_CloudsVolume)) * 2);
		cloudHeight2 *= saturate((cloudHeight2 - (1-_CloudsVolume)*(1-_CloudsVolume)) * 2) * 0.9;
		fixed cldNdotL = saturate(dot(worldNormal, i.lightDir.xyz) - _AmbientLight) + _AmbientLight;

		texGrad = lerp(texGrad, lerp(_CloudsColor2, _CloudsColor1, cloudHeight) * cldNdotL * (max(cloudHeight, cloudHeight2) * 0.5 + 0.5), max(cloudHeight, cloudHeight2) * _CloudsOpacity);
	#endif
	
	/// RIM
	#ifdef _RIM_ON
		fixed rim = FragmentInnerRim(i.NdotX.yz, NdotL.z);
		texGrad = lerp(texGrad, lerp(_RimColor, 1, rim * rim), rim);
	#endif
	
	texGrad = saturate(texGrad);

	return fixed4(texGrad, 1);
}