//Written by ifurkend of Moonflower Carnivore licensed under MIT in 2017.
Shader "Particles/Alpha Blended Cubemap" {
	Properties {
		_TintColor ("Tint Color", Color) = (1, 1, 1, 1)
		_MainTex ("Base (RGB) Mask (A)", 2D) = "white" {}
		[NoScaleOffset] _Cube ("Cubemap", Cube) = "grey" {}
		//_AmbientPow ("Ambient Power", Range(0,1)) = 0.5
		_DLightPow ("Dir Light Power", Range(0,10)) = 0.5
		_Glow ("Intensity", Range(0, 10)) = 0
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "PreviewType" = "Cube"}
		Cull Back
		ZTest Off
		ZWrite Off
		Lighting On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				half3 worldRefl : TEXCOORD1;
				float4 color : COLOR;
			};

			half4 _TintColor;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			samplerCUBE _Cube;
			//half _AmbientPow;
			half _DLightPow;
			half _Glow;

			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				o.color = v.color;
				//o.color.rgb += ShadeSH9(half4(UnityObjectToWorldNormal(v.normal),1)) * _AmbientPow;
				o.color.rgb += _LightColor0.rgb * _DLightPow;
				//o.color.a += _LightColor0.a;
				o.color.rgb += _Glow;

				o.worldRefl = reflect(float3((v.uv.x-0.5)*2,(v.uv.y-0.5)*2,0.67), v.normal);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 cubemap = texCUBE (_Cube, float4(i.worldRefl,1)) * i.color * _TintColor;
				fixed4 maintex2d = tex2D (_MainTex, i.uv);
				fixed4 col;
				col.rgb = cubemap.rgb * maintex2d.rgb;
				col.a = (cubemap.r + cubemap.g + cubemap.b) * 0.33 * cubemap.a * maintex2d.a;
				return col;
			}
		ENDCG
		}
	}
}
