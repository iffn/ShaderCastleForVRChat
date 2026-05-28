Shader "ShaderCastle/Tutorials/Light/SurfaceRadiance"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half3 BRDFLightFactor = half3(0.9, 0.2, 0.2);
                half3 surfaceIrradiance = half3(1.0, 1.0, 1.0);
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + reflectedLight;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}
