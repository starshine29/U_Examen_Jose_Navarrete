Shader "_TS/PPS/Body/Sun"
{
	Properties
	{
		// [Header(Settings)]
		// [KeywordEnum(Orthographic, Perspective)] _Camera("Camera", Float) = 0.0
		// [KeywordEnum(VeryHigh, High, Medium, Low)] _Quality("Quality", Float) = 0.0
		// [Toggle]_QualityLighting("Quality Lighting", Float) = 1
		// [Toggle]_Animate("Animate", Float) = 1
		_AnimationSpeed("Animation Speed", Range(0, 1)) = 0.5
		// [Toggle]_FixPoles("Fix Poles", Float) = 0
		
		// [Header(Main)]
		[NoScaleOffset]_Gradient("Gradient", 2D) = "white" {}
		[NoScaleOffset]_MainTex("Main Texture", 2D) = "black" {}
		_Iris("Iris", Range(0.0, 10.0)) = 0.0

		// [Header(Rim)]
		_RimColor("Color", Color) = (1,1,1,1)
		_RimRadius("Radius", Range(0.1, 10)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"
		}

		Pass // SUN TEXTURE, INNER RIM
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _QUALITY_HIGH _QUALITY_VERYHIGH _QUALITY_MEDIUM _QUALITY_LOW
			#pragma shader_feature _FIXPOLES_OFF _FIXPOLES_ON
			#pragma shader_feature _ANIMATE_OFF _ANIMATE_ON

			#include "PPS_BodyCG.cginc"
			#include "UnityCG.cginc"
			
			sampler2D _Gradient;
			sampler2D _MainTex;
			
			float _Iris;
			#ifdef _ANIMATE_ON
				float _AnimationSpeed;
			#endif

			fixed4 _RimColor;
			
			static const float PlanarBlend = 20;
			
			struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
			
            struct v2f
            {
				float4 vertex : SV_POSITION;
				half3 NdotV : TEXCOORD0; // NdotV (.x), normal.y (.y), NdotV mul (.z)
				fixed3 rim : TEXCOORD1;
				float4 uv : TEXCOORD2;
				#ifdef _FIXPOLES_ON
					float4 uvp : TEXCOORD3;
					#ifndef _QUALITY_LOW
						float4 uvp1 : TEXCOORD4;
						#ifndef _QUALITY_MEDIUM
							float4 uvp2 : TEXCOORD5;
						#endif
					#endif
				#endif
				#ifndef _QUALITY_LOW
					float4 uv1 : TEXCOORD6;
					#ifndef _QUALITY_MEDIUM
						float4 uv2 : TEXCOORD7;
					#endif
				#endif
            };
			
			v2f vert(appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.NdotV.y = v.normal.y;
				o.NdotV.x = saturate(dot(GetWorldViewDirection(mul(unity_ObjectToWorld, v.vertex)), UnityObjectToWorldNormal(v.normal)));
				o.NdotV.z = o.NdotV.x * o.NdotV.x * o.NdotV.x;
				o.NdotV.z *= o.NdotV.z;

				#ifdef _FIXPOLES_ON
					o.uv.xyz = v.vertex.xyz * 0.4;
					o.uvp.xy = (o.uv.xyz * 7 + 0.5).zx;
					o.uvp.zw = (o.uv.xyz * 5 + 0.5).zx;
					#ifndef _QUALITY_LOW
						o.uvp1.xy = (o.uv.xyz * 2 + 0.5).zx;
						o.uvp1.zw = o.uvp.zw;
						#ifndef _QUALITY_MEDIUM
							o.uvp2.xy = o.uvp1.xy;
							o.uvp2.zw = (o.uv.xyz * 11 + 0.5).zx;
						#endif
					#endif
				#endif

				o.uv = float4(v.uv.xy * 7, v.uv.xy * 5);
				#ifndef _QUALITY_LOW
					o.uv1 = float4(v.uv.xy * 2, o.uv.zw);
					#ifndef _QUALITY_MEDIUM
						o.uv2 = float4(o.uv1.xy, v.uv.xy * 11);
					#endif
				#endif

				#ifdef _ANIMATE_ON
					float animationSpeed = _AnimationSpeed * _Time.x;
					o.uv.xy += float2(-1, -1) * 0.21 * animationSpeed;
					o.uv.zw += float2(1, -1) * 0.15 * animationSpeed;

					#ifdef _FIXPOLES_ON
						float cosX = -0.666 * animationSpeed;
						float sinX = sin(cosX);
						cosX = cos(cosX);
						float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
						o.uvp.xy = mul(o.uvp.xy - 0.5, rotationMatrix);
						o.uvp.xy += 0.5;
						
						cosX = 0.45 * animationSpeed;
						sinX = sin(cosX);
						cosX = cos(-cosX);
						rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
						o.uvp.zw = mul(o.uvp.zw - 0.5, rotationMatrix);
						o.uvp.zw += 0.5;
					#endif

					#ifndef _QUALITY_LOW
						o.uv1.xy += float2(-1, 1) * 0.09 * animationSpeed;
						o.uv1.zw += float2(1, 1) * 0.21 * animationSpeed;

						#ifdef _FIXPOLES_ON
							cosX = 0.333 * animationSpeed;
							sinX = sin(-cosX);
							cosX = cos(cosX);
							rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
							o.uvp1.xy = mul(o.uvp1.xy - 0.5, rotationMatrix);
							o.uvp1.xy += 0.5;
							
							cosX = 0.666 * animationSpeed;
							sinX = sin(cosX);
							cosX = cos(cosX);
							rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
							o.uvp1.zw = mul(o.uvp1.zw - 0.5, rotationMatrix);
							o.uvp1.zw += 0.5;
						#endif

						#ifndef _QUALITY_MEDIUM
							o.uv2.xy += float2(1, 1) * 0.2 * animationSpeed;
							o.uv2.zw += float2(1, 1) * 0.33 * animationSpeed;

							#ifdef _FIXPOLES_ON
								cosX = 0.5 * animationSpeed;
								sinX = sin(cosX);
								cosX = cos(cosX);
								rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
								o.uvp2.xy = mul(o.uvp2.xy - 0.5, rotationMatrix);
								o.uvp2.xy += 0.5;
								
								cosX = 0.8 * animationSpeed;
								sinX = sin(cosX);
								cosX = cos(cosX);
								rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
								o.uvp2.zw = mul(o.uvp2.zw - 0.5, rotationMatrix);
								o.uvp2.zw += 0.5;
							#endif

						#endif
					#endif
				#endif
				
				o.rim = 1 - saturate(o.NdotV.x);
				o.rim *= o.rim;

                return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tex;				
				#ifdef _QUALITY_LOW
					tex.rg = tex2D(_MainTex, i.uv.xy).rg;
					tex.rg *= tex2D(_MainTex, i.uv.zw).rg;
					tex.r = tex.g * (tex.r * 0.333 + 0.666) + tex.r * 0.2;
					tex.r *= 0.75;
				#else
					tex.rg = tex2D(_MainTex, i.uv.xy).rg;
					tex.rg *= tex2D(_MainTex, i.uv.zw).rg;
					tex.r *= tex2D(_MainTex, i.uv1.xy).r;
					#ifdef _QUALITY_MEDIUM
						tex.r *= 0.75;
					#else
						tex.r *= tex2D(_MainTex, i.uv2.zw).r;
					#endif

					tex.r += tex2D(_MainTex, i.uv1.zw).g * 0.333;
					#ifdef _QUALITY_MEDIUM
						tex.r += tex.g * ((1-tex.r)) * 0.5;
						tex.r *= 0.666;
					#else
						tex.r += tex2D(_MainTex, i.uv.xy).g * 0.333;
						tex.r *= 0.6;

						tex.g = tex2D(_MainTex, i.uv2.xy).g;
						#ifdef _QUALITY_VERYHIGH
							tex.g *= tex.g * 2;
							tex.g += tex2D(_MainTex, i.uv1.xy).g * 0.5;
							tex.g *= 0.5;
						#endif
						tex.r *= tex.g;
					#endif
				#endif
				
				#ifdef _FIXPOLES_ON
					fixed2 poles;	
					poles.rg = tex2D(_MainTex, i.uvp.xy).rg;
					poles.rg *= tex2D(_MainTex, i.uvp.zw).rg;
					#ifdef _QUALITY_LOW
						poles.r *= poles.g;
						poles.r *= 0.8;
					#else
						poles.r *= tex2D(_MainTex, i.uvp1.xy).r;
						#ifdef _QUALITY_MEDIUM
							poles.r *= 0.75;
						#else
							poles.r *= tex2D(_MainTex, i.uvp2.zw).r;
						#endif

						poles.r += tex2D(_MainTex, i.uvp1.zw).g * 0.333;
						#ifdef _QUALITY_MEDIUM
							poles.r *= 0.75;
						#else
							poles.r += tex2D(_MainTex, i.uvp.xy).g * 0.333;
							poles.r *= 0.6;

							poles.g = tex2D(_MainTex, i.uvp2.xy).g;
							poles.r *= poles.g;
						#endif
					#endif

					fixed blendWeights = saturate(abs(i.NdotV.y) + 0.1 * poles.g * poles.g * poles.g);
					blendWeights = pow(blendWeights, PlanarBlend);
					tex.r = lerp(tex.r, poles.r, blendWeights);
				#endif

				tex.r *= 1 - saturate(i.NdotV.z * _Iris);
				tex.r = lerp(tex.r, 1, 1 - pow(i.NdotV.x, 0.1));
				#if defined(_QUALITY_VERYHIGH) || defined(_QUALITY_HIGH)
					tex.r += 0.075;
				#endif
				tex = tex2D(_Gradient, saturate(tex.r));

				return float4(tex + i.rim, 1);
			}
			ENDCG
		}

		Pass // OUTER RIM
		{
			Blend SrcColor One
			Tags {"LightMode" = "ForwardBase" }
			Zwrite Off
			Cull Front

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma shader_feature _CAMERA_ORTHOGRAPHIC _CAMERA_PERSPECTIVE
			#pragma shader_feature _QUALITYLIGHTING_OFF _QUALITYLIGHTING_ON

			#include "UnityCG.cginc"
			#include "PPS_BodyCG.cginc"

			fixed4 _RimColor;
			float _RimRadius;

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
					#ifdef _QUALITYRIM_ON
						float R : TEXCOORD0;
						float3 worldPos : TEXCOORD1;
					#else
						float2 R : TEXCOORD0;
					#endif
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
				
				float3 worldCenter = mul(unity_ObjectToWorld, fixed4(0,0,0,1));				
				v.vertex.xyz *= 1 + _RimRadius;
				o.vertex = UnityObjectToClipPos(v.vertex);

				worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 viewDir = GetWorldViewDirection(worldPos);
				
				#ifdef _CAMERA_PERSPECTIVE
					float3 rimPos = worldCenter - _WorldSpaceCameraPos;
					o.rimPos = dot(rimPos, viewDir);
					rimPos = viewDir * o.rimPos * sign(-o.rimPos) - rimPos;
					rimPos = mul(unity_WorldToObject, rimPos);
					o.rimPos = dot(rimPos, rimPos);
				#else
					#ifdef _QUALITYRIM_ON
						o.worldPos = UnityObjectToViewPos(v.vertex) - objCenterViewPos; // local-ish Position
					#else
						worldPos = UnityObjectToViewPos(v.vertex) - objCenterViewPos; // local-ish Position
						o.R.g = worldPos.x * worldPos.x + worldPos.y * worldPos.y;
					#endif
				#endif

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = _RimColor;
				#ifdef _CAMERA_PERSPECTIVE
					fixed rim = sqrt(i.rimPos) * sign(i.rimPos - 0.99);
					rim = saturate(1 - abs(1-rim) / _RimRadius); // i.lightVector
				#else
					#ifdef _QUALITYRIM_ON
						float r = i.worldPos.x * i.worldPos.x + i.worldPos.y * i.worldPos.y;
						fixed rim = saturate(1 - abs(r - i.R.r) / (i.R.r * _RimRadius * _RimRadius)) * sign(r - i.R.r);
					#else
						fixed rim = saturate(1 - abs(i.R.g - i.R.r) / (i.R.r * _RimRadius * _RimRadius)) * sign(i.R.g - i.R.r);
					#endif
				#endif

				fixed rim2 = rim * rim;
				rim2 *= rim2;
				rim2 *= rim2;

				return rim * lerp(color, 1, rim2);
			}

			ENDCG
		}
	}
	//Fallback "Diffuse"
    CustomEditor "PPS_BodySunShaderGUI"
}