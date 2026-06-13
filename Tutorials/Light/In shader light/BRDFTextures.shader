Shader "ShaderCastle/Tutorials/Light/BRDFTextures"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
        _normal ("Normal", 2D) = "white" {}
        _arm ("ARM", 2D) = "white" {}
        _ambientLightColor ("Light color", Color) = (0.2, 0.2, 0.2, 1)
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
            half4 _directionalLightColor;
            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normal;
            sampler2D _arm;
            half3 _ambientLightColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                o.uv = TRANSFORM_TEX(v.uv, _albedo);

                return o;
            }

            half3 FresnelReflectionWithSchlickApproximation(float VdotH, float3 albedo, float metallic)
            {
                float specularReflectanceNonMetallic = 0.04; // Standard value for non-metals. Actually ((IoR-1)/(IoR+1))^2, IOR = Index of Refraction
                float3 f0 = lerp(specularReflectanceNonMetallic, albedo, metallic);

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

            float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float NdotV, float NdotL, float3 albedo, float roughness, float metallic)
            {
                float3 halfVectorLightView = normalize(viewDir + lightVector);

                float NdotH = dot(normal, halfVectorLightView);
                float VdotH = dot(viewDir, halfVectorLightView);

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximation(VdotH, albedo, metallic);
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

                float NdotL = dot(worldNormal, lightVector);
                float NdotV = dot(worldNormal, viewVector);
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradiance = radiantIntensity * saturate(NdotL);

                half3 albedo = tex2D(_albedo, i.uv);
                half3 normalMap = tex2D(_normal, i.uv);
                half3 arm = tex2D(_arm, i.uv);
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                half3 emissiveLight = half3(0.0, 0.0, 0.0);
                
                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV, NdotL, albedo.rgb, roughness, metallic);
                half3 directLight = BRDFLightFactor * surfaceIrradiance;

                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = FresnelReflectionWithSchlickApproximation(NdotV, albedo, metallic);
                half3 diffuseAmbient = albedo * _ambientLightColor * (1.0 - metallic);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                half3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;


                half3 surfaceLight = emissiveLight + directLight + ambientLight;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}