Shader "_TS/PPS/Body/Gas No Rim"
{
	Properties
	{
		// [Header(Settings)]
		// [KeywordEnum(Perspective, Orthographic)] _Camera("Camera", Float) = 0.0
		// [KeywordEnum(VeryHigh, High, Medium, Low)] _Quality("Quality", Float) = 0.0
		// [KeywordEnum(Unity, Central, Custom)] _Lighting("Lighting", Float) = 0.0
		_LightDirection("Light Direction", Vector) = (-1,-1,0,1)
		// [Toggle]_QualityLighting("Quality Lighting", Float) = 1
		_AmbientLight("Ambient Light", Range(0.0,0.2)) = 0.05

		// [Header(Main)]
		[NoScaleOffset]_Gradient("Gradient", 2D) = "white" {}
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "gray" {}
		_Distortion("Distortion", Range(0.0, 1.0)) = 0.5
		
		// [Header(Animation)]
		// [Toggle]_Animate("Animate", Float) = 1
		_AnimationSpeed("Animation Speed", Range(0, 1)) = 0.5
		
		// for procedural materials
		// [Header(Rim)]
		_RimColor("Color", Color) = (0.6,0.85,1.0,1.0)
		_RimRadius("Radius", Range(0, 0.1)) = 0.05
		_RimPower("Power", Range(1, 4)) = 2
		_RimOpacity("Opacity", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"
		}

		Pass // SHADOW CASTER PASS
		{
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM

			#pragma target 3.0

			#pragma vertex vert
			#pragma fragment frag

			#include "PPS_ShadowCast.cginc"

			ENDCG
		}

		Pass // PLANET TEXTURE
		{
			Tags {"LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile _RIM_OFF

			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _QUALITY_HIGH _QUALITY_VERYHIGH _QUALITY_MEDIUM _QUALITY_LOW
			#pragma shader_feature _LIGHTING_UNITY _LIGHTING_CENTRAL _LIGHTING_CUSTOM
			#pragma shader_feature _ANIMATE_OFF _ANIMATE_ON
			
			#include "PPS_BodyGasTerrain.cginc"

			ENDCG
		}
	}
	//Fallback "Diffuse"
    CustomEditor "PPS_BodyGasNoRimShaderGUI"
}