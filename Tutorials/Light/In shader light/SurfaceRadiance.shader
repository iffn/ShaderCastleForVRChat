Shader "ShaderCastle/Tutorials/Light/SurfaceRadiance"
{
    Properties
    {
        _BRDFLightFactor ("BRDF Light factor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half3 _BRDFLightFactor;
            
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

                half3 surfaceIrradiance = half3(1.0, 1.0, 1.0);
                half3 reflectedLight = _BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + reflectedLight;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}
