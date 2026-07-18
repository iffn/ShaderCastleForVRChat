Shader "ShaderCastle/Tutorials/Light/SSAO"
{
    Properties
    {
        _albedo ("Albedo", Color) = (1,1,1,1)
        _ambientLightColor ("Ambient light color", Color) = (1,1,1,1)
        _AoRadius ("AO Radius", Range(0.001, 2.0)) = 0.5
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
            
            float3 _albedo;
            float3 _ambientLightColor;
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
                float3 viewPos : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                
                // Pass View Space normal and position for 3D hemisphere calculations
                o.viewNormal = COMPUTE_VIEW_NORMAL; 
                o.viewPos = UnityObjectToViewPos(v.vertex);
                
                return o;
            }

            float GetSSAO(float2 screenUV, float3 viewPos, float3 viewNormal)
            {
                float3 viewSpaceNormal = normalize(viewNormal);
                
                // --- 1. Construct TBN Matrix to orient samples along the normal ---
                // Generate a random vector using high-frequency screen-space noise
                float noiseVal = frac(sin(dot(screenUV, float2(12.9898, 78.233))) * 43758.5453);
                float3 randomVec = normalize(float3(noiseVal * 2.0 - 1.0, frac(noiseVal * 43.123) * 2.0 - 1.0, 0.0));
                
                // Gram-Schmidt process to build an orthogonal basis
                float3 tangent = normalize(randomVec - viewSpaceNormal * dot(randomVec, viewSpaceNormal));
                float3 bitangent = cross(viewSpaceNormal, tangent);
                float3x3 tbn = float3x3(tangent, bitangent, viewSpaceNormal); // Matrix to transform from Tangent to View space

                // --- 2. 3D Hemisphere Loop ---
                int samples = _samples; // Use a const for optimized shaders instead
                float totalOcclusion = 0.0;
                float bias = 0.025; // Prevents self-shadowing artifact on flat surfaces

                for (int sampleIndex = 0; sampleIndex < samples; sampleIndex++)
                {
                    // Generate pseudo-random values (r1, r2) for this specific sample
                    float2 seed = screenUV + float2(sampleIndex * 0.13, sampleIndex * 0.27);
                    float r1 = frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
                    float r2 = frac(sin(dot(seed, float2(39.346, 11.135))) * 43758.5453);

                    // Cosine-weighted hemisphere point generation
                    float phi = 6.28318531 * r1;
                    float cosTheta = sqrt(1.0 - r2);
                    float sinTheta = sqrt(r2);

                    float3 tangentSample = float3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
                    
                    // Distribute points volumetrically within the hemisphere, clustering slightly toward the center
                    float scale = (float)sampleIndex / (float)samples;
                    scale = lerp(0.1, 1.0, scale * scale);
                    tangentSample *= scale;

                    // --- 3. Transform to View Space ---
                    // mul(vector, matrix) multiplies 1x3 by 3x3, handling the Tangent->View rotation
                    float3 viewSamplePos = viewPos + mul(tangentSample, tbn) * _AoRadius;

                    // --- 4. Project Sample to Screen Space ---
                    float4 clipSamplePos = mul(UNITY_MATRIX_P, float4(viewSamplePos, 1.0));
                    clipSamplePos.y *= _ProjectionParams.x; // Handle platform specific inverted Y
                    
                    float2 sampleUV = (clipSamplePos.xy / clipSamplePos.w) * 0.5 + 0.5;

                    // --- 5. Sample Geometry Depth ---
                    float sampleRawDepth = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, sampleUV).r;
                    float geometryLinearDepth = LinearEyeDepth(sampleRawDepth);

                    // --- 6. Occlusion Comparison ---
                    // In Unity, view space Z looks down the negative Z axis. Therefore, distance from camera is -Z.
                    float sampleLinearDepth = -viewSamplePos.z;
                    
                    // Range check: Smoothly fade out occlusion if the background geometry is far away from our sample
                    float rangeCheck = smoothstep(1.0, 0.0, abs(geometryLinearDepth - sampleLinearDepth) / _AoRadius);
                    
                    if (geometryLinearDepth < sampleLinearDepth - bias) 
                    {
                        totalOcclusion += 1.0 * rangeCheck;
                    }
                }
                
                // --- 7. Final Combination ---
                float averageOcclusion = totalOcclusion / (float)samples;
                float finalVisibility = 1.0 - (averageOcclusion * _AoIntensity);
                
                return saturate(finalVisibility); 
            }

            float4 frag (v2f i) : SV_Target 
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                
                float ambientOcclusionFactor = GetSSAO(screenUV, i.viewPos, i.viewNormal); 
                
                float3 surfaceIrradiance = _ambientLightColor * ambientOcclusionFactor; 
                float3 BRDFLightFactor = _albedo; 
                float3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                return float4(reflectedLight, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse" 
}