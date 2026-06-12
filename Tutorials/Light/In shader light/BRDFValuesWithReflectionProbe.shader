Shader "ShaderCastle/Tutorials/Light/BRDFValuesWithReflectionProbe"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _roughness ("Roughness", Range(0, 1)) = 0.5
        _metallic ("Metallic", Range(0, 1)) = 0.5
        _reflectance ("Reflectance", Range(0, 1)) = 0.5
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
            half4 _albedo;
            half4 _directionalLightColor;
            float _roughness;
            float _metallic;
            float _reflectance;
            half3 _ambientLightColor;

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

            half3 FresnelReflectionWithSchlickApproximation(float VdotH, float reflectance, float3 albedo, float metallic)
            {
                float3 reflection = 0.16 * reflectance * reflectance;
                float3 f0 = lerp(reflection, albedo, metallic);

                return f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
            }

            float GGXNormalDistributionFunction(float NdotH, float roughnessSquared)
            {
                float roughnesPow4 = roughnessSquared * roughnessSquared;
                float base = (NdotH * NdotH) * (roughnesPow4 - 1) + 1;
                return roughnesPow4 / (PI * base * base);
            }

            float MicrofacetMaskingGeometryWithSchlickGGXApproximation(float NdotV, float NdotL, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;
                float halfRoughnessSquaredInverse = 1 - halfRoughnessSquared;

                float geometryTermView = NdotV / (NdotV * halfRoughnessSquaredInverse + halfRoughnessSquared);
                float geometryTermLight = NdotL / (NdotL * halfRoughnessSquaredInverse + halfRoughnessSquared);
                
                return geometryTermView * geometryTermLight;
            }

            float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float NdotL, float3 albedo, float roughness, float metallic, float reflectance)
            {
                float3 halfVectorLightView = normalize(viewDir + lightVector);

                float NdotV = dot(normal, viewDir);
                float NdotH = dot(normal, halfVectorLightView);
                float VdotH = dot(viewDir, halfVectorLightView);

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximation(VdotH, reflectance, albedo, metallic);
                float roughnessSquared = roughness * roughness;
                float normalDistribution = GGXNormalDistributionFunction(NdotH, roughnessSquared);
                float microfacetMasking = MicrofacetMaskingGeometryWithSchlickGGXApproximation(NdotV, NdotL, roughnessSquared);

                float divisor = 4.0 * NdotL * NdotV;
                float limitedDivisorFactor = max(1/divisor, 0); // max prevents errors at and past grazing angles
                float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) * limitedDivisorFactor;
                
                float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
                float3 diffuseSubstrateFactor = albedo * remainingDiffuseEnergy * (1.0 - metallic);
                float3 diffuseBRDF = diffuseSubstrateFactor * ONE_OVER_PI;

                return diffuseBRDF + specularBRDF;
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);
                
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half NdotL = dot(worldNormal, lightVector);
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradiance = radiantIntensity * saturate(NdotL);
                
                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotL, _albedo, _roughness, _metallic, _reflectance);
                
                half3 surfaceRadianceDirectionalLight = BRDFLightFactor * surfaceIrradiance;
                half3 surfaceRadianceAmbientLight = _albedo * _ambientLightColor * (1.0 - _metallic); // Turn metalls black when not reflecting for now
                half3 surfaceRadiance = surfaceRadianceDirectionalLight + surfaceRadianceAmbientLight;

                half3 surfaceLight = emissiveLight + surfaceRadiance;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}