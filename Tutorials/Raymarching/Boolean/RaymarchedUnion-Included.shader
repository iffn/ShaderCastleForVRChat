Shader "ShaderCastle/Tutorials/Raymarching/Boolean/RaymarchedUnion-Included"
{
	Properties
	{
		_SphereRadius ("Sphere Radius", Float) = 0.3
		_SphereOffset ("Sphere Offset", Float) = 0.1
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
			
			float _SphereRadius;
			float _SphereOffset;
			float4 _Color;
			
			float sphereSDF(float3 p)
			{
				return length(p) - _SphereRadius;
			}

			float booleanUnion(float a, float b)
			{
				return min(a, b);
			}

			float mainSDF(float3 p)
			{
				float sphere1 = sphereSDF(p - float3(_SphereOffset, 0.0, 0.0));
				float sphere2 = sphereSDF(p + float3(_SphereOffset, 0.0, 0.0));

				return booleanUnion(sphere1, sphere2);
			}

			#include "Assets/ShaderCastleForVRChat/Tutorials/Raymarching/RaymarchCore.cginc"

			ENDCG
		}
	}
}