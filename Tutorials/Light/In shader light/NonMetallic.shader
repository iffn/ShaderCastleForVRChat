Shader "ShaderCastle/Tutorials/Light/NonMetallic"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Light color", Color) = (1,1,1,1)
        _albedo ("Albedo Color", Color) = (1,1,1,1)
        _roughness ("Roughness", Range(0, 1)) = 0.5
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

            #define PI 3.14159265
            #define ONE_OVER_PI 0.31830988618

            float3 _worldLightDirection;
            half3 _directionalLightColor;
            half3 _albedo;
            float _roughness;
            half3 _ambientLightColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            float3 fresnelReflectionNonMetallic(float VdotH)
            {
                float specularReflectance = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
                return specularReflectance + (1.0 - specularReflectance) * pow(1.0 - VdotH, 5.0);
            }
            
            float GGXNormalDistributionFunction(float NdotH, float roughnessSquared)
            {
                float roughnesPow4 = roughnessSquared * roughnessSquared;
                float base = (NdotH * NdotH) * (roughnesPow4 - 1.0) + 1.0;
                return roughnesPow4 / (PI * base * base);
            }

            float MicrofacetMaskingGeometryWithSchlickGGXApproximation(float NdotV, float NdotL, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;
                float halfRoughnessSquaredInverse = 1.0 - halfRoughnessSquared;

                float geometryTermView = NdotV / (NdotV * halfRoughnessSquaredInverse + halfRoughnessSquared);
                float geometryTermLight = NdotL / (NdotL * halfRoughnessSquaredInverse + halfRoughnessSquared);
                
                return geometryTermView * geometryTermLight;
            }

            float3 microfacetBRDF(float roughness, half3 albedo, float3 worldNormal, float3 viewVector, float3 halfVector, float NdotL)
            {
                float NdotV = dot(worldNormal, viewVector);
                float NdotH = dot(worldNormal, halfVector);
                float VdotH = dot(viewVector, halfVector);
                
                float roughnessSquared = roughness * roughness;
                
                float3 fresnelReflection = fresnelReflectionNonMetallic(VdotH);
                float normalDistribution = GGXNormalDistributionFunction(NdotH, roughnessSquared);
                float microfacetMasking = MicrofacetMaskingGeometryWithSchlickGGXApproximation(NdotV, NdotL, roughnessSquared);
                
                float divisor = 4.0 * NdotL * NdotV;
                float limitedDivisorFactor = max(1/divisor, 0); // max prevents errors at and past grazing angles
                float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) * limitedDivisorFactor;
                
                float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
                float3 diffuseBRDF = (albedo * remainingDiffuseEnergy) * ONE_OVER_PI;

                return diffuseBRDF + specularBRDF;
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);

                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightVector + viewVector);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float NdotL = dot(worldNormal, lightVector);
                float3 radiantIntensity = _directionalLightColor;
                float3 surfaceIrradianceDirectionalLight = radiantIntensity * saturate(NdotL);
                
                // How much is reflected:
                half3 BRDFLightFactor = microfacetBRDF(_roughness, _albedo, worldNormal, viewVector, halfVector, NdotL);
                float3 directLight = BRDFLightFactor * surfaceIrradianceDirectionalLight;

                float3 ambientLight = _albedo * _ambientLightColor;

                float3 surfaceLight = directLight + ambientLight;
                
                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}