 Shader "_TS/PPS/Body/Solid"
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
		// [Toggle]_FixPoles("Fix Poles", Float) = 0
		[IntRange]_TexLOD("Texture LOD", Range(0, 3)) = 1

		// [Header(Main)]
		[NoScaleOffset]_Gradient("Gradient", 2D) = "white" {}
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "gray" {}
		[NoScaleOffset]_PlainTex("Plain Texture", 2D) = "gray" {}
		[NoScaleOffset]_MasksTex("Masks Texture", 2D) = "black" {}
		_BumpScale("Bump Scale", Range(0.0, 2.0)) = 1
		
		// [Header(Terrain)]
		_TerrainHeight("Terrain Height", Range(0.5,2.0)) = 1.0
		_TerraformMask("Terraform Mask", Range(0.0,1.0)) = 0.0
		_TerraformFunction("Terraform Function", Range(-1.0,1.0)) = 0.0
		
		// [Header(Ice)]
		[NoScaleOffset]_IceGradient("Gradient", 2D) = "white" {}
		_PolarIce("Polar Ice", Range(0.0,1.0)) = 0.075
		_MountainIce("Mountain Ice", Range(0.0, 1.0)) = 0.1

		// [Header(Liquid)]
		[NoScaleOffset]_LiquidGradient("Gradient", 2D) = "black" {}
		_LiquidHeight("Height", Range(0.0, 1.5)) = 0.5
		_LiquidCoastReach("Coast Reach", Range(10.0, 100.0)) = 100
		_LiquidEmissionColor("Emission Color", Color) = (1,1,1,1)
		_LiquidEmission("Emission", Range(0.0, 1.0)) = 0.2
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularHighlight("Specular Highlight", Range(1.0, 6.0)) = 3.0
		
		// [Header(Lights)]
		[NoScaleOffset]_LightsTex("Texture", 2D) = "black" {}
		_LightsColor("Color", Color) = (1.0,0.67,0.33,1.0)
		_LightsHeightMask("Height Mask", Range(0.0, 1.0)) = 0.5

		// [Header(Clouds)]
		// [Toggle]_Clouds("Clouds", Float) = 0
		// [Toggle]_Animate("Animate", Float) = 1
		[NoScaleOffset]_CloudsTex("Texture", 2D) = "black" {}
		[NoScaleOffset]_CloudsPolarTex("Polar Texture", 2D) = "black" {}
		[IntRange]_CloudsUVTile("Clouds UV Tile", Range(1, 3)) = 2
		_CloudsColor1("Color 1", Color) = (1,1,1,1)
		_CloudsColor2("Color 2", Color) = (1,1,1,1)
		_CloudsVolume("Volume", Range(0.0, 1.0)) = 0.5
		_CloudsOpacity("Opacity", Range(0.0, 1.0)) = 1.0
		_AnimationSpeed("Speed", Range(0.0, 1.0)) = 0.2
		
		// [Header(Rim)]
		_RimColor("Color", Color) = (0.6,0.85,1.0,1.0)
		_RimRadius("Radius", Range(0.0, 0.1)) = 0.05
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

			#pragma multi_compile _RIM_ON

			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _QUALITY_HIGH _QUALITY_VERYHIGH _QUALITY_MEDIUM _QUALITY_LOW
			#pragma shader_feature _FIXPOLES_OFF _FIXPOLES_ON
			#pragma shader_feature _LIGHTING_UNITY _LIGHTING_CENTRAL _LIGHTING_CUSTOM
			#pragma shader_feature _QUALITYLIGHTING_OFF _QUALITYLIGHTING_ON
			#pragma shader_feature _ANIMATE_OFF _ANIMATE_ON
			
		 	#pragma multi_compile _CLOUDS_OFF _CLOUDS_ON
			
			#include "PPS_BodySolidTerrain.cginc"

			ENDCG
		}

		Pass // RIM
		{
			Blend SrcAlpha One
			Tags {"LightMode" = "ForwardBase" }
			Zwrite Off
			Cull Front

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _LIGHTING_UNITY _LIGHTING_CENTRAL _LIGHTING_CUSTOM
			#pragma shader_feature _QUALITYLIGHTING_OFF _QUALITYLIGHTING_ON

			#include "PPS_BodyOuterRim.cginc"

			ENDCG
		}
		
	}
	Fallback "Diffuse"
    CustomEditor "PPS_BodySolidShaderGUI"
}