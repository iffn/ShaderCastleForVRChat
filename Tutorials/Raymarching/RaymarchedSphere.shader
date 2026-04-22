Shader "ShaderCastle/Tutorials/Raymarching/RaymarchedSphere"
{
	Properties
	{
		_SphereRadius ("Sphere Radius", Float) = 0.5
		_SphereColor ("Sphere Color", Color) = (1, 0, 0, 1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Cull Front

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

            

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 localPos : TEXCOORD0;
				float3 cameraPos : TEXCOORD1;
			};

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

            float3 getNormal(float3 p)
            {
                float2 e = float2(0.001, 0.0);
                
                float3 n = float3(
                    mainSDF(p + e.xyy) - mainSDF(p - e.xyy),
                    mainSDF(p + e.yxy) - mainSDF(p - e.yxy),
                    mainSDF(p + e.yyx) - mainSDF(p - e.yyx)
                );
                
                return normalize(n);
            }

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.localPos = v.vertex.xyz;
				o.cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				float3 rayDir = normalize(i.localPos - i.cameraPos);
				float3 rayOrigin = i.cameraPos;

				float t = 0;
				for (int step = 0; step < 64; step++)
				{
					float3 p = rayOrigin + rayDir * t;
					float distanceToShape = mainSDF(p);

                    if (distanceToShape < 0.001)
                    {
                        float3 n = getNormal(p); // The "Universal" way
                        float3 lightDir = normalize(float3(1, 1, -1));
                        float diff = max(0.2, dot(n, lightDir));
                        return _SphereColor * diff;
                    }

					t += distanceToShape;
					if (t > 10.0) break;
				}

				discard;
				return 0;
			}
			ENDCG
		}
	}
}