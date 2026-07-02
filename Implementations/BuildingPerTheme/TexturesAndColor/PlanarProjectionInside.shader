Shader "ShaderCastle/Implementations/BuildingPerTheme/TexturesAndColor/PlanarProjectionInside"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define PI 3.14159265
            #define ONE_OVER_PI 0.31830988618

            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;
            half3 _ambientLightColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
            };
            
            void GetProjectionData(float3 position, float3 projectionVector, out float2 uv, out float3 tangent, out float3 bitangent)
            {
                float3 normal = normalize(projectionVector);
                float3 verticalRef = (abs(normal.y) > 0.999) ? float3(0, 0, 1) : float3(0, 1, 0);

                float3 horizontalAxis = normalize(cross(verticalRef, normal));
                float3 verticalAxis = cross(normal, horizontalAxis);
                
                float uRaw = dot(position, horizontalAxis);
                float vRaw = dot(position, verticalAxis);
                
                float blend = smoothstep(0.3, 0.6, abs(normal.y));
                
                uv = lerp(float2(uRaw, vRaw), float2(vRaw, uRaw), blend);
                tangent = lerp(horizontalAxis, verticalAxis, blend);
                bitangent = lerp(verticalAxis, horizontalAxis, blend);
            }

            v2f vert (appdata v) {
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                
                float2 uv;
                float3 worldTangent, worldBitangent;
                GetProjectionData(worldPos, worldNormal, uv, worldTangent, worldBitangent);

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = worldPos;
                o.uv = TRANSFORM_TEX(uv, _albedo);
                o.worldNormal = worldNormal;
                //o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                //o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);

                return o;
            }

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

            half3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                half4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
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

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float NdotV01 = saturate(dot(worldNormal, viewVector));

                half3 albedo = tex2D(_albedo, i.uv).rgb;
                half3 arm = tex2D(_arm, i.uv).rgb;
                float ambientOcclusion = arm.r;
                float roughness = arm.g * 3.0;
                float metallic = arm.b;

                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                half3 diffuseAmbient = albedo * _ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                half3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;

                half3 color = ambientLight;

                return half4 (color, 1.0);
            }
            ENDCG
        }
    }
}