Shader "ShaderCastle/Tutorials/Light/UnityMultiplelLights"
{
    Properties
    {
        _albedo ("Albedo", color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            half3 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_LIGHTING_COORDS(2, 3) // Macro that writes required data to TEXCOORD 2 and 3
            };
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                half3 emissiveLight = half3(0.0, 0.0, 0.0);
                
                float3 worldNormal = normalize(i.worldNormal);
                
                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 radiantIntensity = _LightColor0.rgb * attenuation;
                
                float NdotL01 = saturate(dot(worldNormal, lightVector));
                half3 surfaceIrradiance = radiantIntensity * NdotL01;
                
                half3 BRDFLightFactor = _albedo;
                half3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                surfaceRadiance += UNITY_LIGHTMODEL_AMBIENT.rgb * _albedo;
                
                half3 surfaceLight = emissiveLight + surfaceRadiance;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd // Tells Unity to run this pass for all extra lights

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            half3 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_LIGHTING_COORDS(2, 3)
            };
            
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                
                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }

                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 radiantIntensity = _LightColor0.rgb * attenuation;

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                half3 surfaceIrradiance = radiantIntensity * NdotL01;

                half3 BRDFLightFactor = _albedo;
                half3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                half3 surfaceLight = surfaceRadiance; // No emmision in second pass

                return half4(surfaceLight, 0.0); // Add 0 to alpha in second pass
            }
            ENDCG
        }
    }
}