Shader "ShaderCastle/Tutorials/Raymarching/Shapes/RaymarchedSphere-Included"
{
	Properties
	{
		_SphereRadius ("Sphere Radius", Float) = 0.5
		_SphereColor ("Sphere Color", Color) = (1, 0, 0, 1)
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
			float4 _SphereColor;
			
			float sphereSDF(float3 p)
			{
				return length(p) - _SphereRadius;
			}

			float mainSDF(float3 p)
			{
				return sphereSDF(p);
			}

			#include "Assets/ShaderCastleForVRChat/Tutorials/Raymarching/RaymarchCore.cginc"

			ENDCG
		}
	}
}