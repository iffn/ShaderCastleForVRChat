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
            
            half3 _emission;

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

            half4 frag () : SV_Target {
                half3 emissiveLight = _emission;
                half3 reflectedLight = half3(0.0, 0.0, 0.0); // No reflective light

                half3 surfaceLight = emissiveLight + reflectedLight;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}
