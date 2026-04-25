Shader "ShaderCastle/Tutorials/Raymarching/Shapes/RaymarchedRoundedBox-Included"
{
	Properties
	{
		_SideLength ("Side length", Float) = 0.5
		_Radius ("Radius", Float) = 0.1
		_Color ("Sphere Color", Color) = (1, 0, 0, 1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }//

        Cull Front

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float _SideLength;
			float _Radius;
			float4 _Color;
			
			float roundedBoxSDF(float3 p)
			{
				float3 q = abs(p) - _SideLength * 0.5 + _Radius;
				return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - _Radius;
			}

			float mainSDF(float3 p)
			{
				return roundedBoxSDF(p);
			}

			#include "Assets/ShaderCastleForVRChat/Tutorials/Raymarching/RaymarchCore.cginc"

			ENDCG
		}
	}
}