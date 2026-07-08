Shader "ShaderCastle/Tutorials/Light/SSAO"
{
    Properties
    {
        _albedo ("Albedo", Color) = (1,1,1,1)
        _ambientLightColor ("Ambient light color", Color) = (1,1,1,1)
        _AoRadius ("AO Radius", Range(0.001, 0.1)) = 0.01
        _AoIntensity ("AO Intensity", Range(0, 5)) = 1.5
        _samples ("Samples", Range(1, 64)) = 16
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

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_CameraDepthTexture);
            
            half3 _albedo;
            half3 _ambientLightColor;
            float _AoRadius;
            float _AoIntensity;
            int _samples;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 viewNormal : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                
                o.viewNormal = COMPUTE_VIEW_NORMAL; 
                
                return o;
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
                int samples = _samples; // Use a const for optimized shaders instead
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

            half4 frag (v2f i) : SV_Target 
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                float ambientOcclusionFactor = GetSSAO(screenUV, i.viewNormal); // 0 = fully occluded, 1 = unoccluded
                
                half3 surfaceIrradiance = _ambientLightColor * ambientOcclusionFactor; // Ambient occlusion is applied to the ambient light
                half3 BRDFLightFactor = _albedo; 
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                return half4(reflectedLight, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse" // Required so the camera generates the _CameraDepthTexture depth pass in Built-in rendering pipeline
}