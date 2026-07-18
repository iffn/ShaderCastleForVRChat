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

            float3 _albedo;
            float3 _ambientLightColor;
            
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
                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float3 surfaceIrradiance = _ambientLightColor;
                
                // How much is reflected:
                float3 BRDFLightFactor = _albedo; // Simplified model: The light gets reflected in all directions equally.
                float3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                float3 surfaceLight = emissiveLight + reflectedLight;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}
