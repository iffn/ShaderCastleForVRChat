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

            float3 fresnelReflectionWithSchlickApproximationNonMetallic(float cosSpecularAngle01)
            {
                float specularReflectance = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
                return specularReflectance + (1.0 - specularReflectance) * pow(1.0 - cosSpecularAngle01, 5.0);
            }
            
            float GGXNormalDistributionFunction(float NdotH01, float roughnessSquared)
            {
                float roughnesPow4 = roughnessSquared * roughnessSquared;
                float base = (NdotH01 * NdotH01) * (roughnesPow4 - 1.0) + 1.0;
                return roughnesPow4 / (PI * base * base);
            }

            float MicrofacetMaskingGeometryWithSchlickGGXApproximation(float NdotV01, float NdotL01, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;
                float halfRoughnessSquaredInverse = 1.0 - halfRoughnessSquared;

                float geometryTermView = NdotV01 / (NdotV01 * halfRoughnessSquaredInverse + halfRoughnessSquared);
                float geometryTermLight = NdotL01 / (NdotL01 * halfRoughnessSquaredInverse + halfRoughnessSquared);
                
                return geometryTermView * geometryTermLight;
            }

            float3 microfacetBRDF(float roughness, half3 albedo, float3 worldNormal, float3 viewVector, float3 halfVector, float NdotL01, float NdotV01)
            {
                float NdotH01 = saturate(dot(worldNormal, halfVector));
                float VdotH01 = saturate(dot(viewVector, halfVector));
                
                float roughnessSquared = roughness * roughness;
                
                float3 fresnelReflection = fresnelReflectionWithSchlickApproximationNonMetallic(VdotH01);
                float normalDistribution = GGXNormalDistributionFunction(NdotH01, roughnessSquared);
                float microfacetMasking = MicrofacetMaskingGeometryWithSchlickGGXApproximation(NdotV01, NdotL01, roughnessSquared);
                
                float divisor = max(4.0 * NdotL01 * NdotV01, 0.0001); // Preventing division by 0 errors. In this case, the specularBRDF would evaluate to 0 / 0.0001 = 0
                float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) / divisor;
                
                float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
                float3 diffuseBRDF = (albedo * remainingDiffuseEnergy) * ONE_OVER_PI;

                return diffuseBRDF + specularBRDF;
            }

            half3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                half4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);

                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightVector + viewVector);
                
                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                float3 radiantIntensity = _directionalLightColor;
                float3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL01;
                
                half3 BRDFLightFactor = microfacetBRDF(_roughness, _albedo, worldNormal, viewVector, halfVector, NdotL01, NdotV01);
                float3 directLight = BRDFLightFactor * surfaceIrradianceDirectionalLight;
                
                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, _roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationNonMetallic(NdotV01);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;

                half3 diffuseAmbient = _albedo * _ambientLightColor * remainingAmbientDiffuseEnergy;
                half3 ambientLight = diffuseAmbient + specularAmbient;

                float3 surfaceLight = directLight + ambientLight;
                
                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}