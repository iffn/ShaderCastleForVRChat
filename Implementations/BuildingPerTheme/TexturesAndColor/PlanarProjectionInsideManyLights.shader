Shader "ShaderCastle/Implementations/BuildingPerTheme/TexturesAndColor/PlanarProjectionInsideManyLights"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "green" {}
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
        _pointLightColor ("Point light color", Color) = (0.2, 0.2, 0.2, 1)
        _pattern ("Pattern", Range(0.5, 3.0)) = 1.0
        _intensity ("Intensity", Range(0.0, 500.0)) = 1.0
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
            #include "Assets/ShaderCastleForVRChat/Implementations/Includes/PBRFunctions.cginc"

            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;
            float3 _ambientLightColor;
            float3 _pointLightColor;
            float _pattern;
            float _intensity;

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
                float3 localPos : TEXCOORD5;
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
                o.worldTangent = worldTangent;
                o.worldBitangent = worldBitangent;
                o.localPos = v.vertex;
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldPos = i.worldPos;
                float3 objectOrigin = unity_ObjectToWorld._m03_m13_m23;

                float pattern = _pattern;
                float halfPattern = pattern * 0.5;

                float3 searchPos = worldPos + normalize(i.worldNormal) * (pattern * 0.55);

                // Offset search position to be relative to the local origin before snapping
                float3 localSearchPos = searchPos - objectOrigin;
                float3 localLightPos = (floor(localSearchPos / pattern) * pattern) + halfPattern.xxx;

                // Shift back to world space
                float3 worldLightPosition = localLightPos + objectOrigin;

                float3 lightDelta = worldLightPosition - worldPos;
                float lightDistance = length(lightDelta);

                // All vectors are normalized and point away from the surface
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightVector;
                lightVector = lightDelta / max(0.0001, lightDistance);

                float pointLightIntensity = _intensity;

                float3 radiantIntensity = _pointLightColor * pointLightIntensity / (PIx4 * lightDistance * lightDistance);

                float4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal);
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
                float3 worldNormal = normalize(mul(tangentNormal, tbn));

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));
                float3 surfaceIrradiance = radiantIntensity * NdotL01;

                float3 albedo = tex2D(_albedo, i.uv).rgb;
                float3 arm = tex2D(_arm, i.uv).rgb;
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                float3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV01, NdotL01, albedo.rgb, roughness, metallic);
                float3 directLight = BRDFLightFactor * surfaceIrradiance;

                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                float3 diffuseAmbient = albedo * _ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                float3 specularAmbient = indirectSpecularLight * indirectFresnel;
                float3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;

                float3 surfaceLight = directLight + ambientLight;

                return float4 (surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}