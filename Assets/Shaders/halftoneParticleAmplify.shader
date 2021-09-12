// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HalfTone/AmplifyExample"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Off
						  ZWrite Off
			  Blend DstColor Zero
			  ColorMask RGBA
			  ZWrite Off
			  ZTest Always

		
		Pass
		{
			CGPROGRAM
			#pragma enable_d3d11_debug_symbols

			#pragma target 4.5 
			#pragma vertex vert
			#pragma fragment frag

			#include "Assets/Shaders/particlesStruct.cginc"
			StructuredBuffer<halftonePoint> _visiblePoints;


			struct appdata
			{
				float4 vertex : POSITION;
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 ase_texcoord1 : TEXCOORD1;
			};

			uniform sampler2D _MainTex;
			uniform fixed4 _Color;
			uniform float2 _Size;
			float4 MyCustomExpression18( uint vertexId , float2 paritcleSize , out float3 uv )
			{
				uint instanceId = (uint)floor(vertexId/6.0f);
				float2 originCenter = _visiblePoints[instanceId].position;
				float density = _visiblePoints[instanceId].density;
				float2 size = paritcleSize *  density;
				uint vertIndex = vertexId % 6;
				if (vertIndex == 0) 
				{
					uv = float3(0.0f, 0.0f, density);
					return float4(originCenter + float2(-1.0f, -1.0f) * size,0.5f, 1.0f);
				}else if(vertIndex == 1)
				{
					uv = float3(1.0f, 0.0f, density);
					return float4(originCenter + float2(1.0f, -1.0f) * size, 0.5f, 1.0f);
				}
				else if (vertIndex == 2) 
				{
					uv = float3(1.0f, 1.0f, density);
					return float4(originCenter + float2(1.0f,1.0f) * size, 0.5f, 1.0f);
				}
				else if (vertIndex == 3)
				{
					uv = float3(1.0f, 1.0f, density);
					return float4(originCenter + float2(1.0f, 1.0f) * size, 0.5f, 1.0f);
				}
				else if (vertIndex == 4)
				{
					uv = float3(0.0f, 1.0f, density);
					return float4(originCenter + float2(-1.0f, 1.0f) * size, 0.5f, 1.0f);
				}
				else 
				{
					uv = float3(0.0f, 0.0f, density);
					return float4(originCenter + float2(-1.0f, -1.0f) * size, 0.5f, 1.0f);	
				}
			}
			
			
			v2f vert ( appdata v , uint ase_vertexId : SV_VertexID)
			{
				v2f o;
				
				// ase common template code
				uint vertexId18 = ase_vertexId;
				float2 paritcleSize18 = _Size;
				float3 uv18 = float3( 0.5,0.5,0 );
				float4 localMyCustomExpression18 = MyCustomExpression18( vertexId18 , paritcleSize18 , uv18 );
				
				float3 vertexToFrag28 = uv18;
				o.ase_texcoord1.xyz = vertexToFrag28;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				
				v.vertex.xyz += localMyCustomExpression18.xyz;
				o.vertex = float4(v.vertex.xyz,1.0f);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 myColorVar;
				// ase common template code
				float3 vertexToFrag28 = i.ase_texcoord1.xyz;
				float temp_output_44_0 = (vertexToFrag28).z;
				float temp_output_70_0 = ( temp_output_44_0 * 0.99999 );
				float clampResult69 = clamp( tex2D( _MainTex, (vertexToFrag28).xy ).a , 0.0 , temp_output_70_0 );
				float4 lerpResult29 = lerp( float4( 1,1,1,1 ) , _Color , ( ( clampResult69 / temp_output_70_0 ) * temp_output_44_0 ));
				
				
				myColorVar = lerpResult29;
				return myColorVar;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
2560;51;2560;1367;2029.829;422.0781;1;True;True
Node;AmplifyShaderEditor.VertexIdVariableNode;8;-1433.186,103.5672;Inherit;False;0;1;INT;0
Node;AmplifyShaderEditor.Vector2Node;74;-1169.829,505.9219;Inherit;False;Global;_Size;_Size;1;0;Create;True;0;0;False;0;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CustomExpressionNode;18;-1121.367,168.4879;Inherit;False;uint instanceId = (uint)floor(vertexId/6.0f)@$float2 originCenter = _visiblePoints[instanceId].position@$float density = _visiblePoints[instanceId].density@$float2 size = paritcleSize *  density@$uint vertIndex = vertexId % 6@$if (vertIndex == 0) ${$	uv = float3(0.0f, 0.0f, density)@$	return float4(originCenter + float2(-1.0f, -1.0f) * size,0.5f, 1.0f)@$}else if(vertIndex == 1)${$	uv = float3(1.0f, 0.0f, density)@$	return float4(originCenter + float2(1.0f, -1.0f) * size, 0.5f, 1.0f)@$}$else if (vertIndex == 2) ${$	uv = float3(1.0f, 1.0f, density)@$	return float4(originCenter + float2(1.0f,1.0f) * size, 0.5f, 1.0f)@$}$else if (vertIndex == 3)${$	uv = float3(1.0f, 1.0f, density)@$	return float4(originCenter + float2(1.0f, 1.0f) * size, 0.5f, 1.0f)@$}$else if (vertIndex == 4)${$	uv = float3(0.0f, 1.0f, density)@$	return float4(originCenter + float2(-1.0f, 1.0f) * size, 0.5f, 1.0f)@$}$else ${$	uv = float3(0.0f, 0.0f, density)@$	return float4(originCenter + float2(-1.0f, -1.0f) * size, 0.5f, 1.0f)@	$};4;False;3;True;vertexId;OBJECT;0;In;uint;Half;False;True;paritcleSize;FLOAT2;0,0;In;;Float;False;True;uv;FLOAT3;0.5,0.5,0;Out;;Float;False;My Custom Expression;True;False;0;3;0;OBJECT;0;False;1;FLOAT2;0,0;False;2;FLOAT3;0.5,0.5,0;False;2;FLOAT4;0;FLOAT3;3
Node;AmplifyShaderEditor.VertexToFragmentNode;28;-296.6387,-87.4071;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;25;-13.93443,-105.0613;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;67;-222.2769,-283.6669;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;211.4038,156.1002;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;0.99999;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;44;25.0456,59.38983;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;408.4038,-13.89978;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;129.5999,-235.7;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;69;549.1752,-149.1817;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;711.4038,-69.89978;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;888.2562,77.31297;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;68;586.552,-464.4235;Inherit;False;0;0;_Color;Shader;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;205.9439,-446.8195;Inherit;False;Property;_Color;_Color;0;0;Create;True;0;0;False;0;1,0,0,1;1,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;29;777.3613,-371.4071;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;1137.111,221.1712;Float;False;True;2;ASEMaterialInspector;0;10;HalfTone/AmplifyExample;1a63319d79a962d41831052d63cb77a6;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;6;2;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;True;True;True;True;True;0;False;-1;False;True;2;False;-1;True;7;False;-1;False;True;1;RenderType=Opaque=RenderType;False;0;False;False;False;False;False;False;False;False;False;False;True;5;4;Pragma;enable_d3d11_debug_symbols;False;;Custom;Include;;False;;Native;Include;;True;365fff1eb9961da4781c85318a70bb56;Custom;Custom;StructuredBuffer<halftonePoint> _visiblePoints@;False;;Custom;;0;0;Standard;0;0;1;True;False;0
WireConnection;18;0;8;0
WireConnection;18;1;74;0
WireConnection;28;0;18;3
WireConnection;25;0;28;0
WireConnection;44;0;28;0
WireConnection;70;0;44;0
WireConnection;70;1;71;0
WireConnection;4;0;67;0
WireConnection;4;1;25;0
WireConnection;69;0;4;4
WireConnection;69;2;70;0
WireConnection;72;0;69;0
WireConnection;72;1;70;0
WireConnection;45;0;72;0
WireConnection;45;1;44;0
WireConnection;29;1;68;0
WireConnection;29;2;45;0
WireConnection;66;0;29;0
WireConnection;66;1;18;0
ASEEND*/
//CHKSM=A3D07EBA74797E9E5E2A4E3C6EAAD4DF428FE89A