Shader "ShaderCastle/Tutorials/Light/UnitySingleLight"
{
    Properties
    {
        _albedo ("Albedo", color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc" // Macro with Unity light functions. Defines attenuation variable

            float3 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_LIGHTING_COORDS(2, 3) // Hidden data channels for light/shadow maps
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o); // Populates the internal light coordinates
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 emissiveLight = float3(0.0, 0.0, 0.0);
                
                float3 worldNormal = normalize(i.worldNormal);
                
                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos); // Unity macro that writes to the attenuation variable defined in AutoLight.cginc
                float3 radiantIntensity = _LightColor0.rgb * attenuation; // Correct Unity formula, _LightColor0.rgb also holds intensity.
                
                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float3 surfaceIrradiance = radiantIntensity * NdotL01;

                surfaceIrradiance += UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                float3 BRDFLightFactor = _albedo;
                float3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;
                
                float3 surfaceLight = emissiveLight + surfaceRadiance;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}