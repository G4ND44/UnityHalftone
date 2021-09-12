// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/dotShape"
{
	Properties
	{
		
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
			};

						
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float2 uv018 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv03 = i.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 break6 = ( ( uv03 * float2( 2,2 ) ) - float2( 1,1 ) );
				float temp_output_12_0 = ( ( ( atan2( break6.x , break6.y ) + UNITY_PI ) / ( 2.0 * UNITY_PI ) ) * ( 24.0 * UNITY_PI ) );
				float2 lerpResult34 = lerp( ( uv018 * float2( 2,2 ) ) , ( uv018 * sin( temp_output_12_0 ) ) , float2( 0.1,0.1 ));
				float4 temp_cast_0 = (sqrt( ( 1.0 - saturate( length( ( lerpResult34 - float2( 1,1 ) ) ) ) ) )).xxxx;
				
				
				finalColor = temp_cast_0;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
7;7;1906;1010;1392.978;66.05828;1.706257;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-986.299,278;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-667.8997,336.0997;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;5;-512.4003,392.3004;Inherit;False;2;0;FLOAT2;1,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;6;-304,260.5;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;2;-187,-57.5;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;10;-138,297.5;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;7;121,382.5;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;67,146.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;13;481.6999,427.7132;Inherit;False;1;0;FLOAT;24;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;465,-158.5;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;656.0436,105.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-890.7981,588.3643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;11;995.2432,-18.70902;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-606.1172,910.6012;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-572.3988,646.4641;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;34;-322.4922,844.0504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-39.09831,860.1223;Inherit;False;2;0;FLOAT2;1,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;14;223.6166,936.5757;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;116.165,621.4019;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;16;326.165,674.4019;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;17;685.165,662.4019;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;29;903.3902,494.8815;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;-2.32;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;667.6587,520.9217;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;1162.539,620.0776;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1419.539,617.0776;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;1714.082,610.7166;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;880.9279,200.6278;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20.99;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;902.0281,830.4904;Float;False;True;2;ASEMaterialInspector;0;1;Unlit/dotShape;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;0
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;6;0;5;0
WireConnection;2;0;6;0
WireConnection;2;1;6;1
WireConnection;9;0;2;0
WireConnection;9;1;10;0
WireConnection;8;0;9;0
WireConnection;8;1;7;0
WireConnection;12;0;8;0
WireConnection;12;1;13;0
WireConnection;11;0;12;0
WireConnection;35;0;18;0
WireConnection;35;1;11;0
WireConnection;19;0;18;0
WireConnection;34;0;19;0
WireConnection;34;1;35;0
WireConnection;20;0;34;0
WireConnection;14;0;20;0
WireConnection;15;0;14;0
WireConnection;16;0;15;0
WireConnection;17;0;16;0
WireConnection;29;0;30;0
WireConnection;31;0;29;0
WireConnection;32;0;31;0
WireConnection;36;0;32;0
WireConnection;36;1;32;0
WireConnection;26;0;12;0
WireConnection;1;0;17;0
ASEEND*/
//CHKSM=CBF4919B72D74BA071D9D026EB142F18857DD558