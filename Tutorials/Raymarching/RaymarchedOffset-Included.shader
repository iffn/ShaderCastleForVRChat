Shader "ShaderCastle/Tutorials/Raymarching/Boolean/RaymarchedOffset-Included"
{
	Properties
	{
		_SphereRadius ("Sphere Radius", Float) = 0.3
		_SphereOffset ("Sphere Offset", Vector) = (0.2, 0.0, 0.0)
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
			float3 _SphereOffset;
			float4 _Color;
			
			float sphereSDF(float3 p)
			{
				return length(p) - _SphereRadius;
			}

			float mainSDF(float3 p)
			{
				return sphereSDF(p - _SphereOffset);
			}

			#include "Assets/ShaderCastleForVRChat/Tutorials/Raymarching/RaymarchCore.cginc"

			ENDCG
		}
	}
}