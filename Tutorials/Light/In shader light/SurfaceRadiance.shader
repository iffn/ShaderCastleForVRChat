Shader "ShaderCastle/Tutorials/Light/SurfaceRadiance"
{
    Properties
    {
        _albedo ("Albedo", Color) = (1,1,1,1)
        _ambientLightColor ("Ambient light color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half3 _albedo;
            half3 _ambientLightColor;
            
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

                // Light hitting the surface:
                half3 surfaceIrradiance = _ambientLightColor;
                
                // How much is reflected:
                half3 BRDFLightFactor = _albedo; // Simplified model: The light gets refelcted in all directions equally.
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + reflectedLight;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}
