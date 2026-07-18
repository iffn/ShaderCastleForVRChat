Shader "ShaderCastle/Tutorials/Light/BRDFTextures"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            #include "Assets/ShaderCastleForVRChat/Implementations/Includes/PBRFunctions.cginc"

            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
                UNITY_LIGHTING_COORDS(5, 6)
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }

                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos); // Unity macro that writes to the attenuation variable defined in AutoLight.cginc
                half3 radiantIntensity = _LightColor0.rgb * attenuation; // Correct Unity formula, _LightColor0.rgb also holds intensity.

                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal);
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
                float3 worldNormal = normalize(mul(tangentNormal, tbn));

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));
                half3 surfaceIrradiance = radiantIntensity * NdotL01;

                half3 albedo = tex2D(_albedo, i.uv).rgb;
                half3 arm = tex2D(_arm, i.uv).rgb;
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                half3 emissiveLight = half3(0.0, 0.0, 0.0);
                
                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV01, NdotL01, albedo.rgb, roughness, metallic);
                half3 directLight = BRDFLightFactor * surfaceIrradiance;

                half3 ambientLightColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                half3 diffuseAmbient = albedo * ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                half3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;


                half3 surfaceLight = emissiveLight + directLight + ambientLight;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}