Shader "ShaderCastle/Tutorials/Light/SurfaceLight"
{
    Properties
    {
        _emission ("Emission", Color) = (0.9, 0.1, 0.1, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            float3 _emission;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag () : SV_Target {
                float3 emissiveLight = _emission;
                float3 reflectedLight = float3(0.0, 0.0, 0.0); // No reflective light

                float3 surfaceLight = emissiveLight + reflectedLight;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}
