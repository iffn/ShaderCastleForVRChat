Shader "ShaderCastle/Tutorials/Light/UnityMultiplelLights"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        sampler2D _albedo;
        float4 _albedo_ST;
        sampler2D _normalMap;
        sampler2D _arm;

        #define PI 3.14159265
        #define ONE_OVER_PI 0.31830988618

        half3 FresnelReflectionWithSchlickApproximationBRDF(float VdotH01, float3 albedo, float metallic)
        {
            float specularReflectanceNonMetallic = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
            float3 f0 = lerp(specularReflectanceNonMetallic, albedo, metallic);

            return f0 + (1.0 - f0) * pow(1.0 - VdotH01, 5.0);
        }

        half3 fresnelReflectionWithSchlickApproximationAmbient(float3 albedo, float metallic, float roughness, float NdotV01)
        {
            float specularReflectanceNonMetallic = 0.04;
            float3 specularReflectanceNormal = lerp(specularReflectanceNonMetallic, albedo, metallic);
            float3 specularReflectanceGrazing = max(1.0 - roughness, specularReflectanceNormal);
            return specularReflectanceNormal + (specularReflectanceGrazing - specularReflectanceNormal) * pow(1.0 - NdotV01, 5.0);
        }

        float GGXNormalDistributionFunction(float NdotH01, float roughnessSquared)
        {
            float roughnesPow4 = roughnessSquared * roughnessSquared;
            float base = (NdotH01 * NdotH01) * (roughnesPow4 - 1) + 1;
            return roughnesPow4 / (PI * base * base);
        }

        float MicrofacetMaskingGeometryWithSchlickGGXApproximation(float NdotV01, float NdotL01, float roughnessSquared)
        {
            float halfRoughnessSquared = roughnessSquared * 0.5;
            float halfRoughnessSquaredInverse = 1 - halfRoughnessSquared;

            float geometryTermView = NdotV01 / (NdotV01 * halfRoughnessSquaredInverse + halfRoughnessSquared);
            float geometryTermLight = NdotL01 / (NdotL01 * halfRoughnessSquaredInverse + halfRoughnessSquared);
            
            return geometryTermView * geometryTermLight;
        }

        float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float NdotV01, float NdotL01, float3 albedo, float roughness, float metallic)
        {
            float3 halfVectorLightView = normalize(viewDir + lightVector);

            float NdotH01 = saturate(dot(normal, halfVectorLightView));
            float VdotH01 = saturate(dot(viewDir, halfVectorLightView));

            float3 fresnelReflection = FresnelReflectionWithSchlickApproximationBRDF(VdotH01, albedo, metallic);
            float roughnessSquared = roughness * roughness;
            float normalDistribution = GGXNormalDistributionFunction(NdotH01, roughnessSquared);
            float microfacetMasking = MicrofacetMaskingGeometryWithSchlickGGXApproximation(NdotV01, NdotL01, roughnessSquared);

            float divisor = max(4.0 * NdotL01 * NdotV01, 0.0001); // Preventing division by 0 errors. In this case, the specularBRDF would evaluate to 0 / 0.0001 = 0
            float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) / divisor;

            float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
            float3 diffuseSubstrateFactor = albedo * remainingDiffuseEnergy * (1.0 - metallic);
            float3 diffuseBRDF = diffuseSubstrateFactor * ONE_OVER_PI;

            return diffuseBRDF + specularBRDF;
        }
        ENDCG

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                half4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
            }

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 radiantIntensity = _LightColor0.rgb * attenuation;
                
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

                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                half3 diffuseAmbient = albedo * UNITY_LIGHTMODEL_AMBIENT.rgb * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                half3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;

                half3 surfaceLight = emissiveLight + directLight + ambientLight;

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
            #pragma multi_compile_fwdadd
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            half3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                half4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
            }

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightVector;
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 radiantIntensity = _LightColor0.rgb * attenuation;
                
                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal);
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
                float3 worldNormal = normalize(mul(tangentNormal, tbn));

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));
                half3 surfaceIrradiance = radiantIntensity * NdotL01;

                half3 albedo = tex2D(_albedo, i.uv).rgb;
                half3 arm = tex2D(_arm, i.uv).rgb;
                float roughness = arm.g;
                float metallic = arm.b;

                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV01, NdotL01, albedo.rgb, roughness, metallic);
                half3 directLight = BRDFLightFactor * surfaceIrradiance;

                half3 surfaceLight = directLight;

                return half4(surfaceLight, 0.0);
            }
            ENDCG
        }
    }
}