Shader "ShaderCastle/Tutorials/Light/SurfaceIrradiance"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Light color", Color) = (1,1,1,1)
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
            half3 _directionalLightColor;
            half3 _albedo;

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

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -normalize(_worldLightDirection);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float NdotL = dot(worldNormal, lightVector); // The dot product describes how much light hits the surface given a direction
                NdotL = saturate(NdotL); // Saturate clamps it to 0...1 and removes the negative light direction
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradiance = radiantIntensity * NdotL;
                
                // How much is reflected:
                half3 BRDFLightFactor = _albedo; // Simplified model: The light gets reflected in all directions equally.
                half3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                half3 surfaceLight = emissiveLight + surfaceRadiance;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}