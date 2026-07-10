Shader "ShaderCastle/Implementations/BuildingPerTheme/TexturesAndColor/PlanarProjectionOutside"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
        _AoRadius ("AO Radius", Range(0.001, 0.1)) = 0.0328
        _AoIntensity ("AO Intensity", Range(0, 5)) = 1.6
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
            #include "AutoLight.cginc" // Macro with Unity light functions. Defines attenuation variable

            #define PI 3.14159265
            #define ONE_OVER_PI 0.31830988618

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_CameraDepthTexture);

            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;
            float _AoRadius;
            float _AoIntensity;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                float3 viewNormal : TEXCOORD6;
                UNITY_LIGHTING_COORDS(7, 8)
                UNITY_VERTEX_OUTPUT_STEREO
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
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = worldPos;
                o.uv = TRANSFORM_TEX(uv, _albedo);
                o.worldNormal = worldNormal;
                o.worldTangent = worldTangent;
                o.worldBitangent = worldBitangent;
                TRANSFER_VERTEX_TO_FRAGMENT(o); // Populates the internal light coordinates
                
                o.screenPos = ComputeScreenPos(o.pos);
                o.viewNormal = COMPUTE_VIEW_NORMAL; 
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

            float GetSSAO(float2 screenUV, float3 viewNormal)
            {
                // --- Current Pixel Depth & Normal Setup ---
                float currentRawDepth = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, screenUV).r;
                float currentLinearDepth = LinearEyeDepth(currentRawDepth); 
                
                float3 viewSpaceNormal = normalize(viewNormal);
                float angleToCamera = saturate(dot(viewSpaceNormal, float3(0, 0, -1))); 
                float angleBasedBias = 0.02 * (1.0 - angleToCamera); // Reduced baseline bias since the geometric warp handles self-occlusion
                
                // --- Screen-Space Axis Alignment Math ---
                float2 screenNormalXY = viewSpaceNormal.xy; // Extract the 2D direction the surface is tilting on your screen
                float2 tiltDirection = normalize(screenNormalXY + float2(1e-5, 1e-5)); // Establish a safe unit vector pointing up the slope
                float2 tangentDirection = float2(-tiltDirection.y, tiltDirection.x); // Establish a perpendicular axis running flat along the surface
                
                float surfaceTiltSquish = saturate(viewSpaceNormal.z); // Scale factor: 1.0 when facing the camera directly, approaching 0.0 at sharp angles
                float2 asymmetricAirShift = tiltDirection * (1.0 - surfaceTiltSquish) * 0.4; // Offset vector to shift the kernel into the air and away from the wall
                
                // --- Dithering Noise Generation ---
                float2 pixelCoordinates = screenUV * _ScreenParams.xy;
                float randomNoiseValue = sin(dot(pixelCoordinates, float2(12.9898, 78.233))) * 43758.5453; 
                float randomNoiseAngle = frac(randomNoiseValue) * 6.2831853; 
                
                float sinAngle, cosAngle;
                sincos(randomNoiseAngle, sinAngle, cosAngle); 
                float2x2 noiseRotationMatrix = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);

                // --- Curved Asymmetric Spiral Loop ---
                const int samples = 16;
                float totalOcclusion = 0.0;
                const float goldenAngleRadians = 2.39996323; 

                for (int sampleIndex = 0; sampleIndex < samples; sampleIndex++)
                {
                    float spiralRadius = sqrt((sampleIndex + 0.5) / samples); 
                    float spiralAngle = sampleIndex * goldenAngleRadians; 
                    
                    float2 baseSpiralOffset = float2(cos(spiralAngle), sin(spiralAngle)) * spiralRadius;
                    float2 rotatedOffset = mul(noiseRotationMatrix, baseSpiralOffset); 
                    
                    // Transform the uniform 2D circle into an asymmetric, surface-aligned dome shape
                    float tangentComponent = rotatedOffset.x; // Unaltered width along the flat horizon of the surface
                    float tiltComponent = rotatedOffset.y * surfaceTiltSquish; // Compress the kernel depth-wise based on perspective tilt
                    
                    // Combine the components and apply the shift to generate the asymmetric D-shaped silhouette
                    float2 warpedOffset = (tangentDirection * tangentComponent) + (tiltDirection * tiltComponent) + (asymmetricAirShift * spiralRadius);
                    
                    float2 neighborSampleUV = screenUV + (warpedOffset * _AoRadius) / currentLinearDepth; 
                    
                    float neighborRawDepth = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, neighborSampleUV).r;
                    float neighborLinearDepth = LinearEyeDepth(neighborRawDepth);
                    
                    float depthDifference = currentLinearDepth - neighborLinearDepth; 
                    
                    if (depthDifference > angleBasedBias && depthDifference < 0.5) 
                    {
                        float proximityAttenuation = 1.0 - smoothstep(angleBasedBias, 0.5, depthDifference); 
                        totalOcclusion += proximityAttenuation;
                    }
                }
                
                // --- Final Combination ---
                float averageOcclusion = totalOcclusion / (float)samples;
                float finalVisibility = 1.0 - (averageOcclusion * _AoIntensity);
                
                return saturate(finalVisibility); 
            }

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                half3 radiantIntensity = _LightColor0.rgb * attenuation;

                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal);
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
                float3 worldNormal = normalize(mul(tangentNormal, tbn));

                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float NdotV01 = saturate(dot(worldNormal, viewVector));
                half3 surfaceIrradiance = radiantIntensity * NdotL01;

                half3 albedo = tex2D(_albedo, i.uv).rgb;
                half3 arm = tex2D(_arm, i.uv).rgb;
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                half3 BRDFLightFactor = microfacetBRDF(worldNormal, viewVector, lightVector, NdotV01, NdotL01, albedo.rgb, roughness, metallic);
                half3 directLight = BRDFLightFactor * surfaceIrradiance;

                half3 ambientLightColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 indirectSpecularLight = SampleReflectionProbe(viewVector, worldNormal, roughness);
                float3 indirectFresnel = fresnelReflectionWithSchlickApproximationAmbient(albedo, metallic, roughness, NdotV01);
                float3 remainingAmbientDiffuseEnergy = 1.0 - indirectFresnel;
                half3 diffuseAmbient = albedo * ambientLightColor * remainingAmbientDiffuseEnergy * (1.0 - metallic);
                half3 specularAmbient = indirectSpecularLight * indirectFresnel;
                half3 ambientLight = (diffuseAmbient + specularAmbient) * ambientOcclusion;

                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float ambientOcclusionFactor = GetSSAO(screenUV, i.viewNormal); // 0 = fully occluded, 1 = unoccluded
                ambientLight *= ambientOcclusionFactor;

                half3 surfaceLight = directLight + ambientLight;

                return half4 (surfaceLight, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse" // Required so the camera generates the _CameraDepthTexture depth pass in Built-in rendering pipeline
}