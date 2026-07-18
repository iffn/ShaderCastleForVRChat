Shader "ShaderCastle/Tutorials/Light/BRDFValues"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _roughness ("Roughness", Range(0, 1)) = 0.5
        _metallic ("Metallic", Range(0, 1)) = 0.5
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

            #define PI 3.14159265
            #define ONE_OVER_PI 0.31830988618

            float3 _worldLightDirection;
            float4 _directionalLightColor;
            float4 _albedo;
            float _roughness;
            float _metallic;
            float3 _ambientLightColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            float3 FresnelReflectionWithSchlickApproximationBRDF(float VdotH01, float3 albedo, float metallic)
            {
                float specularReflectanceNonMetallic = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
                float3 f0 = lerp(specularReflectanceNonMetallic, albedo, metallic);

                return f0 + (1.0 - f0) * pow(1.0 - VdotH01, 5.0);
            }

            float3 fresnelReflectionWithSchlickApproximationAmbient(float3 albedo, float metallic, float roughness, float NdotV01)
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

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximationBRDF(albedo, metallic, VdotH01);
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

            float3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                float4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
            }

            float4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);
                
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));
                
                float3 radiantIntensity = _directionalLightColor;
                float3 surfaceIrradiance = radiantIntensity * NdotL01;
                
                float3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV01, NdotL01, _albedo, _roughness, _metallic);
                float3 directLight = BRDFLightFactor * surfaceIrradiance;
                
                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, _roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(_albedo, _metallic, _roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                float3 diffuseAmbient = _albedo * _ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - _metallic);
                float3 specularAmbient = indirectSpecularLight * indirectFresnel;
                float3 ambientLight = diffuseAmbient + specularAmbient;

                float3 surfaceLight = emissiveLight + directLight + ambientLight;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}