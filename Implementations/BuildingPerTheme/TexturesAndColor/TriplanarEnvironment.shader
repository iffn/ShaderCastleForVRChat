Shader "ShaderCastle/Implementations/BuildingPerTheme/TexturesAndColor/TriplanarMapping"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
        _Sharpness ("Sharpness", Range(1, 64)) = 2.0
        _MainTexScale ("Texture Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;
            float3 _ambientLightColor;
            float _Sharpness;
            float _MainTexScale;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBitangent : TEXCOORD3;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            float3 triplanarColor(float3 pos, float3 normal) {
                float3 weights = abs(normal);
                weights = pow(weights, _Sharpness);
                weights /= (weights.x + weights.y + weights.z);

                float3 direction = sign(normal);

                float2 uvX = float2(pos.z * direction.x, pos.y) * _MainTexScale;
                float2 uvY = float2(pos.x * direction.y, pos.z) * _MainTexScale;
                float2 uvZ = float2(pos.x * -direction.z, pos.y) * _MainTexScale;

                float4 colX = tex2D(_albedo, uvX);
                float4 colY = tex2D(_albedo, uvY);
                float4 colZ = tex2D(_albedo, uvZ);

                float4 finalCol = colX * weights.x + colY * weights.y + colZ * weights.z;
                return finalCol;
            }

            float3 SampleReflectionProbe(float3 viewVector, float3 worldNormal, float roughness)
            {
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = roughness * 6.0; 
                float4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                return DecodeHDR(encodedReflection, unity_SpecCube0_HDR);
            }

            float3 fresnelReflectionWithSchlickApproximationAmbient(float3 albedo, float metallic, float roughness, float NdotV01)
            {
                float specularReflectanceNonMetallic = 0.04;
                float3 specularReflectanceNormal = lerp(specularReflectanceNonMetallic, albedo, metallic);
                float3 specularReflectanceGrazing = max(1.0 - roughness, specularReflectanceNormal);
                return specularReflectanceNormal + (specularReflectanceGrazing - specularReflectanceNormal) * pow(1.0 - NdotV01, 5.0);
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float NdotV01 = saturate(dot(worldNormal, viewVector));
                
                float3 albedo = triplanarColor(i.worldPos, worldNormal);
                float roughness = 0.8;
                float metallic = 0.0;
                float ambientOcclusion = 1.0;

                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                float3 diffuseAmbient = albedo * _ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                float3 specularAmbient = indirectSpecularLight * indirectFresnel;
                float3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;

                return float4 (ambientLight, 1.0);
            }
            ENDCG
        }
    }
}