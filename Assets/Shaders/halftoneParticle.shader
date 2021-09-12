Shader "Custom/HalftoneParticle"
{
	Properties
	{
		_Color("Draw Color", Color) = (1, 1, 1, 1)
		_MainTex("Dot Gradient", 2D) = "white" {}
	    _Efficiency("Ink Effiency", Float) = 1.0
	}
		SubShader
	{
		 Tags {"Queue" = "Overlay" "RenderType" = "Transparent" }
		LOD 100
		Cull off
	  ZWrite Off
	  Blend DstColor Zero
	  AlphaToMask On
	  ColorMask RGBA
	  ZWrite Off
	  ZTest Always


		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols
			#pragma target 4.5 // minumum for compute shaders

			#include "UnityCG.cginc"
			#include "particlesStruct.cginc"


			StructuredBuffer<halftonePoint> _visiblePoints;
			uniform half _Efficiency;
			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform half2 _Size;

			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 uv : TEXCOORD0;
			};


			v2f vert(uint verId : SV_VertexID)
			{
				v2f o;
				uint instanceId = (uint)floor(verId / 6.0f);
				float2 originCenter = _visiblePoints[instanceId].position;
				float density = _visiblePoints[instanceId].density;
				float2 size = _Size * density;
				uint vertIndex = verId % 6;
				if (vertIndex == 0) 
				{
					o.pos = float4(originCenter + float2(-1.0f, -1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(0.0f, 0.0f, density);
				}else if(vertIndex == 1)
				{
					o.pos = float4(originCenter + float2(1.0f, -1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(1.0f, 0.0f, density);
				}
				else if (vertIndex == 2) 
				{
					o.pos = float4(originCenter + float2(1.0f,1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(1.0f, 1.0f, density);
				}
				else if (vertIndex == 3)
				{
					o.pos = float4(originCenter + float2(1.0f, 1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(1.0f, 1.0f, density);
				}
				else if (vertIndex == 4)
				{
					o.pos = float4(originCenter + float2(-1.0f, 1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(0.0f, 1.0f, density);
				}
				else 
				{
					o.pos = float4(originCenter + float2(-1.0f, -1.0f) * size, 0.5f, 1.0f);
					o.uv = float3(0.0f, 0.0f, density);
				}

				return o;
			}




			fixed4 frag(v2f i) : SV_Target
			{
				float3 uvAndDensity = i.uv;
				float dotGradient =tex2D(_MainTex, i.uv.xy).a;
				float clampmaxRange = uvAndDensity.z * 0.99999f;
				float clampedDot = clamp(dotGradient, 0.0f, clampmaxRange)/ clampmaxRange;
				half4 rasterColor = _Color;
				return fixed4(lerp(half3(1.0f, 1.0f, 1.0f), rasterColor.rgb, clampedDot * uvAndDensity.z), 1.0);


			}

			ENDCG
		}
	}
		Fallback Off
}
