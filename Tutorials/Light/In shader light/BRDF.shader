Shader "ShaderCastle/Tutorials/Light/BRDF"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _roughness ("Roughness", Range(0, 1)) = 0.5
        _metallic ("Metallic", Range(0, 1)) = 0.5
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
            half4 _albedo;
            half4 _light_color;
            half4 _ambient_light_color;
            float _roughness;
            float _metallic;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            float3 HalfVectorLightViewNormalized(float3 lightDir, float3 viewDir)
            {
                return normalize(viewDir + lightDir);
            }
            
            half3 FresnelReflectionWithSchlickApproximation(float3 viewDir, float3 halfVectorLightView)
            {
                float3 reflectanceForPerpendicularIncidence = float3(0.8, 0.2, 0.2);

                float3 powBase = (1 - dot(viewDir, halfVectorLightView));

                float3 pow5 = powBase * powBase * powBase * powBase * powBase;
                
                return reflectanceForPerpendicularIncidence + (1 - reflectanceForPerpendicularIncidence) * pow5;
            }

            half3 FresnelReflectionWithSchlickApproximation(float3 viewDir, float3 halfVectorLightView, float3 albedo, float metallic)
            {
                float3 dielectricReflectance = float3(0.04, 0.04, 0.04); // Baseline reflection for non-metals, typically 4%

                float3 reflectanceForPerpendicularIncidence = lerp(dielectricReflectance, albedo, metallic);

                float3 powBase = saturate(1.0 - dot(viewDir, halfVectorLightView));

                float3 pow5 = powBase * powBase * powBase * powBase * powBase;
                
                return reflectanceForPerpendicularIncidence + (1.0 - reflectanceForPerpendicularIncidence) * pow5;
            }

            float GGXNormalDistributionFunction(float NdotH, float roughnessSquared)
            {
                float pi = 3.141593;
                
                float base = (NdotH * NdotH) * (roughnessSquared - 1) + 1;

                return roughnessSquared / (pi * base * base);
            }

            float MicrofacetMaskingGeometryWithSchlikGGXApproximation(float NdotV, float NdotL, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;
                float halfRoughnessSquaredInverse = 1 - halfRoughnessSquared;

                float geometryTermView = NdotV / (NdotV * halfRoughnessSquaredInverse + halfRoughnessSquared);
                float geometryTermLight = NdotL / (NdotL * halfRoughnessSquaredInverse + halfRoughnessSquared);

                return geometryTermView * geometryTermLight;
            }

            float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightDir, float roughness)
            {
                float3 halfVectorLightView = HalfVectorLightViewNormalized(lightDir, viewDir);

                float NdotV = dot(normal, viewDir);
                float NdotL = dot(normal, lightDir);
                float NdotH = dot(normal, halfVectorLightView);

                // Prevent backlighting and division by 0
                NdotV = max(NdotV, 0.0001);
                NdotL = max(NdotL, 0.0001);
                NdotH = max(NdotH, 0.0001);

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximation(viewDir, halfVectorLightView);
                
                float roughnessSquared = roughness * roughness;

                float normalDistribution = GGXNormalDistributionFunction(NdotH, roughnessSquared);

                float microfacetMasking = MicrofacetMaskingGeometryWithSchlikGGXApproximation(NdotV, NdotL, roughnessSquared);


                return (fresnelReflection * normalDistribution * microfacetMasking) / (4 * NdotL * NdotV);
            }

            half4 frag (v2f i) : SV_Target {
                float3 normal = normalize(i.normal);
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);


                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half3 BRDFLightFactor = _albedo + microfacetBRDF(worldNormal, viewDir, -normalized_world_light_direction, _roughness);

                half NdotL = dot(worldNormal, normalized_world_light_direction);
                half3 randiantIntensity = half3(1.0, 1.0, 1.0);
                half3 surfaceIrradiance = randiantIntensity * NdotL;
                
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + reflectedLight;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}