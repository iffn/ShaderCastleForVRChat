Shader "ShaderCastle/Tutorials/Light/BRDFTextures"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,1)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
        _normal ("Normal", 2D) = "white" {}
        _arm ("ARM", 2D) = "white" {}
        _reflectance ("Reflectance", Range(0, 1)) = 0.5
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

            float3 _world_light_direction;
            half4 _light_color;
            half4 _ambient_light_color;
            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normal;
            sampler2D _arm;
            float _reflectance;
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
            
            half3 FresnelReflectionWithSchlickApproximation(float3 viewDir, float3 halfVectorLightView)
            {
                float3 reflectanceForPerpendicularIncidence = float3(0.8, 0.2, 0.2);

                float3 powBase = (1 - dot(viewDir, halfVectorLightView));

                float3 pow5 = powBase * powBase * powBase * powBase * powBase;
                
                return reflectanceForPerpendicularIncidence + (1 - reflectanceForPerpendicularIncidence) * pow5;
            }

            half3 FresnelReflectionWithSchlickApproximation(float VdotH, float reflectance, float3 albedo, float metallic)
            {
                float3 reflection = 0.16 * reflectance * reflectance;
                float f0 = lerp(reflection, albedo, metallic);

                return f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
            }

            float GGXNormalDistributionFunction(float NdotH, float roughnessSquared)
            {
                float pi = 3.141593;
                
                float roughnesPow4 = roughnessSquared * roughnessSquared;

                float base = (NdotH * NdotH) * (roughnesPow4 - 1) + 1;

                return roughnesPow4 / (pi * base * base);
            }

            float MicrofacetMaskingGeometryWithSchlikGGXApproximation(float NdotV, float NdotL, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;
                float halfRoughnessSquaredInverse = 1 - halfRoughnessSquared;

                float geometryTermView = NdotV / (NdotV * halfRoughnessSquaredInverse + halfRoughnessSquared);
                //return geometryTermView;

                float geometryTermLight = NdotL / (NdotL * halfRoughnessSquaredInverse + halfRoughnessSquared);
                //return geometryTermLight;
                return geometryTermView * geometryTermLight;
            }

            float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float NdotL, float3 albedo, float roughness, float metallic, float reflectance)
            {
                float3 halfVectorLightView = normalize(viewDir + lightVector);

                float NdotV = dot(normal, viewDir);
                float NdotH = dot(normal, halfVectorLightView);
                float VdotH = dot(viewDir, halfVectorLightView);

                // Prevent backlighting and division by 0
                NdotV = max(NdotV, 0.0001);
                NdotH = max(NdotH, 0.0001);

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximation(VdotH, reflectance, albedo, metallic);
                float roughnessSquared = roughness * roughness;
                float normalDistribution = GGXNormalDistributionFunction(NdotH, roughnessSquared);
                float microfacetMasking = MicrofacetMaskingGeometryWithSchlikGGXApproximation(NdotV, NdotL, roughnessSquared);

                float3 specularBRDF = (fresnelReflection * normalDistribution * microfacetMasking) / (4.0 * NdotL * NdotV);

                float3 remainingDiffuseEnergy = 1.0 - fresnelReflection;
                float3 diffuseSubstrateFactor = albedo * remainingDiffuseEnergy * (1.0 - metallic);
                float oneOverPi = 0.31830988618;
                float3 diffuseBRDF = diffuseSubstrateFactor * oneOverPi;

                return diffuseBRDF + specularBRDF;
            }

            half4 frag (v2f i) : SV_Target {
                float3 normal = normalize(i.normal);
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 lightVector = -normalized_world_light_direction;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                half3 albedo = tex2D(_albedo, i.uv);
                half3 normalMap = tex2D(_normal, i.uv);
                half3 arm = tex2D(_arm, i.uv);
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half NdotL = dot(worldNormal, lightVector);
                NdotL = max(NdotL, 0.0001);
                half3 randiantIntensity = half3(1.0, 1.0, 1.0);
                half3 surfaceIrradiance = randiantIntensity * NdotL;
                
                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewDir, lightVector, NdotL, albedo.rgb, roughness, metallic, _reflectance);
                
                half3 surfaceRadianceDirectionalLight = BRDFLightFactor * surfaceIrradiance;
                half3 surfaceRadianceAmbientLight = albedo * _ambientLightColor * ambientOcclusion * (1.0 - metallic);
                half3 surfaceRadiance = surfaceRadianceDirectionalLight + surfaceRadianceAmbientLight;

                half3 emittedLight = emissiveLight + surfaceRadiance;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}