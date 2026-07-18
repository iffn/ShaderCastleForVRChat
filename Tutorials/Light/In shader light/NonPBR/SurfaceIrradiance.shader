Shader "ShaderCastle/Tutorials/Light/SurfaceIrradiance"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Directional light color", Color) = (1,1,1,1)
        _albedo ("Albedo", Color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _worldLightDirection;
            float3 _directionalLightColor;
            float3 _albedo;

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
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -normalize(_worldLightDirection);

                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float3 radiantIntensity = _directionalLightColor;
                float NdotL = dot(worldNormal, lightVector); // The dot product describes how much light hits the surface given a direction
                float NdotL01 = saturate(NdotL);
                float3 surfaceIrradiance = radiantIntensity * NdotL01; // Saturate clamps it to 0...1 and removes the negative light direction
                
                // How much is reflected:
                float3 BRDFLightFactor = _albedo; // Simplified model: The light gets reflected in all directions equally.
                float3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                float3 surfaceLight = emissiveLight + surfaceRadiance;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}