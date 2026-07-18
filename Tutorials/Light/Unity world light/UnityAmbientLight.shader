Shader "ShaderCastle/Tutorials/Light/AmbientLight"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // Required for _LightColor0

            float4 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float3 surfaceIrradiance = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
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