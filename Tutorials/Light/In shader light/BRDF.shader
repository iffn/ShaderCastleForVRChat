Shader "ShaderCastle/Tutorials/Light/BRDF"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _smoothness ("Smoothness", Range(0, 1)) = 0.5
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
            float _smoothness;
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

            float3 HalfVectorLightViewNormalized(float3 lightVector, float3 viewDir)
            {
                return normalize(lightVector + lightVector);
            }
            
            half3 FresnelReflectionWithSchlickApproximation(float3 viewDir, float3 halfVectorLightView)
            {
                float3 reflectanceForPerpendicularIncidence = float3(0.8, 0.8, 0.8);

                float3 powBase = (1 - dot(viewDir, halfVectorLightView));

                float3 pow5 = powBase * powBase * powBase * powBase * powBase;
                
                return reflectanceForPerpendicularIncidence + (1 - reflectanceForPerpendicularIncidence) * pow5;
            }

            float GGXNormalDistributionFunction(float3 normal, float3 halfVectorLightView, float roughnessSquared)
            {
                float pi = 3.141593
                
                float NdotH = dot(normal, halfVectorLightView);
                float base = (pi * (NdotH * NdotH) * (roughnessSquared - 1) - 1);

                return roughnessSquared / (base * base);
            }

            float MicrofacetMaskingGeometryWithSchlikGGXApproximation(float NdotV, float3 viewVector, float roughnessSquared)
            {
                float halfRoughnessSquared = roughnessSquared * 0.5;

                return NdotV / (NdotV * (1 - halfRoughnessSquared) + halfRoughnessSquared);
            }

            float3 microfacetBRDF(float3 normal, float3 viewDir, float3 lightVector, float roughness)
            {
                float3 halfVectorLightView = HalfVectorLightViewSquared(lightVector viewDir);

                float3 fresnelReflection = FresnelReflectionWithSchlickApproximation(float3 viewDir, float3 halfVectorLightView);
                
                float roughnessSquared = roughness * roughness;

                float GGXNormalDistribution = GGXNormalDistributionFunction(normal, halfVectorLightView, roughnessSquared);

                float microfacetMasking = MicrofacetMaskingGeometryWithSchlikGGXApproximation(normal, lightVector, viewVector, roughnessSquared);

                float3 NdotV = dot(normal, viewVector);
            }


            half4 frag (v2f i) : SV_Target {


                float3 normal = normalize(i.normal);
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);


                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half3 BRDFLightFactor = _albedo;

                float3 normalized_world_light_direction = normalize(_world_light_direction);
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