Shader "_TS/PPS/Planetary Ring"
{
	Properties
	{
		// [KeywordEnum(Perspective, Orthographic)] _Camera("Camera", Float) = 0.0
		[Toggle]_Simple("Simple Rendering", Float) = 0
		[NoScaleOffset]_Gradient("Gradient", 2D) = "gray" {}
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
		_Radius("Radius", Range(0,2)) = 1
		_Noise("Noise", Range(0.5, 2.0)) = 1
		_Shadow("Shadow", Range(0,1)) = 0.75
		[Toggle]_Animate("Animate", Float) = 0
		_AnimationSpeed("Animation Speed", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags
		{
			"RenderType"="AlphaTest"
			"Queue"="AlphaTest+1"
			"IgnoreProjector"="True"
            "PreviewType"="Plane"
		}

    	ZWrite Off
		Cull Back

		Pass // OUTER RIM
		{
    		Blend One OneMinusSrcColor
			Tags {"LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _ANIMATE_OFF _ANIMATE_ON
			#pragma shader_feature _SIMPLE_OFF _SIMPLE_ON
			#pragma multi_compile_fwdadd_fullshadows

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			sampler2D _Gradient, _MainTex;

			half _Radius;
			half _Noise;
			fixed _Shadow;
			#ifdef _ANIMATE_ON
				fixed _AnimationSpeed;
			#endif

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				SHADOW_COORDS(1)
#ifdef _CAMERA_PERSPECTIVE
				float2 screenPos : TEXCOORD2;
#endif
			};

			v2f vert(appdata v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
#ifdef _CAMERA_PERSPECTIVE
				o.screenPos = ComputeScreenPos(o.pos).zw;
#endif

				o.uv = (v.uv.xyxy - 0.5) * 2; // izhodisce
				o.uv.zw *= 2;

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed r1 = sqrt(i.uv.x * i.uv.x + i.uv.y * i.uv.y);
				r1 = saturate(r1 * (1+_Radius) - _Radius);
				fixed r2 = sqrt(i.uv.z * i.uv.z + i.uv.w * i.uv.w);

				fixed angle1b = 0;
#ifndef _SIMPLE_ON					
				angle1b = (atan2(i.uv.w, i.uv.z)) * UNITY_INV_TWO_PI;
#endif		
#ifdef _ANIMATE_ON
				angle1b = (angle1b + (_Time.x % UNITY_TWO_PI) * _AnimationSpeed) % 1;
#endif	
				fixed2 height = tex2D(_MainTex, float2(angle1b, (r2 * (1+_Radius) - _Radius) * _Noise)).gb;
				height.r *= height.g * 0.333 + 0.666;
				height.g = 0;
				height += tex2D(_MainTex, float2(0, r1)).rg;
				height.r *= 0.5;
				
				fixed4 tex = tex2D(_Gradient, height);
				tex *= tex.a;
				tex *= saturate(1 - abs(r1 - 0.55) * 2.23);

#ifdef _CAMERA_PERSPECTIVE
				i.screenPos.x = i.screenPos.x / i.screenPos.y;
				tex *= _ProjectionParams.x < 0 ? 1 - i.screenPos.x : i.screenPos.x;
#endif
				return tex * lerp(1, SHADOW_ATTENUATION(i), _Shadow);
			}

			ENDCG
		}
	}
	Fallback "Diffuse" // for shadows
	CustomEditor "PPS_PlanetaryRingShaderGUI"
}