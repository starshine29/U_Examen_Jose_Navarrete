///////////////
// LIGHTING
///////////////

float4 _LightDirection;
fixed _AmbientLight;

fixed4 GetLightDirection(half3 worldPos)
{
	fixed4 lightDirection;
	#ifdef _LIGHTING_CENTRAL
		lightDirection = fixed4(normalize(float3(normalize(-worldPos.xy), -0.8)), 1);
	#else 
		#ifdef _LIGHTING_CUSTOM
			_LightDirection.w = max(0, _LightDirection.w);
			lightDirection = fixed4(normalize(-_LightDirection.xyz), _LightDirection.w);
		#else
			half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - worldPos.xyz;
			lightDirection = fixed4(
				normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
				lerp(1, 1/length(fragmentToLightSource), _WorldSpaceLightPos0.w) );
		#endif
	#endif

	return lightDirection;
}

fixed3 GetWorldViewDirection(float3 worldPos)
{
	#ifdef _CAMERA_ORTHOGRAPHIC
		return mul(UNITY_MATRIX_MV[2].xyz, unity_WorldToObject);
	#else
		return normalize(_WorldSpaceCameraPos - worldPos);
	#endif
}

///////////////
// RIM
///////////////

#ifdef _RIM_ON
	float _RimPower;
	fixed4 _RimColor;
	fixed _RimOpacity;

	fixed2 VertexInnerRim(fixed3 wViewDir, half3 wNormal, fixed3 wLightDirection)
	{
		fixed2 NdotX;

		NdotX.x = 1 - saturate(dot(wViewDir, wNormal)); // NdotV
		NdotX.y = dot(wViewDir, wLightDirection); // LdotV

		return NdotX;
	}

	fixed3 FragmentInnerRim(fixed2 NdotX, fixed3 NdotL)
	{
		fixed rim = pow(NdotX.x, _RimPower) * NdotL;
		rim *= (1 - NdotX.y * lerp(lerp(0.5, 1, sign(NdotX.y)), -2 * NdotX.x * NdotX.x,  sign(NdotX.y) * NdotX.y * NdotX.y));

		return rim * _RimOpacity;
	}
#endif

///////////////
// EFFECTS
///////////////

#ifdef _EFFECTS_ON
	sampler2D _SpecGlossMap; // EffectTex
	fixed4 _BulbsColor, _CracksColor;
	fixed _EffectAmount;
	// float _CracksEmission;
	// fixed4 _CracksEmissionColor;

	fixed4 EffectsNormalBumpStage(fixed4 tex, fixed4 texEffect, fixed globalEffectMasks)
	{
		texEffect.rg = texEffect.rg * 2 - 1; // LIGHTING
		
		// effectMask je v tex.a
		tex.a = abs(texEffect.b - texEffect.a) * sqrt(_EffectAmount) * globalEffectMasks;

		tex.rg = (tex.rg + texEffect.rg * tex.a * sqrt(_EffectAmount)) / (1 + abs(tex.a));
		tex.b -= saturate((texEffect.b - texEffect.a) * globalEffectMasks) * _EffectAmount * 0.2;

		return tex;
	}

	fixed3 EffectsColoringStage(fixed3 texGrad, fixed2 effectMasks, fixed globalEffectMasks)
	{
		return texGrad * lerp(1, _CracksColor * effectMasks.r + _BulbsColor * effectMasks.g, globalEffectMasks * max(effectMasks.g, effectMasks.r));
	}
#endif