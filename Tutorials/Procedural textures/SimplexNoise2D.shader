Shader "ShaderCastlev/Tutorials/ProceduralTextures/SimplexNoise2D"
{
    Properties
    {
        _zoom ("Zoom", float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            float _zoom;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float hash11(float p) {

                if(p == -0)
                    p = 0;

                uint h = asuint(p+0.0);

                h ^= 0x27D4EB2DU; 

                h = h * 1103515245U + 12345U;
                h ^= (h >> 16);
                h *= 0x85ebca6bU;
                h ^= (h >> 13);
                h *= 0xc2b2ae35U;
                h ^= (h >> 16);

                return float(h & 0x00ffffffu) / float(0x01000000u);
            }

            float hash21(float2 p) {
                return hash11(hash11(p.x) + p.y);
            }

            float2 hash22(float2 p)
            {
                float a = hash11(hash11(p.x) + p.y);
                float b = hash11(a);
                return float2(a, b);
            }

            float simplexNoise(float2 uv)
            {
                // Skewing factors for 2D
                const float SKEW_FACTOR_2D = 0.366025403;   // (sqrt(3.0) - 1.0) / 2.0
                const float UNSKEW_FACTOR_2D = 0.211324865; // (3.0 - sqrt(3.0)) / 6.0

                // Skewing the grid to get triangles
                float skewAmount = (uv.x + uv.y) * SKEW_FACTOR_2D;
                float2 skewedGridId = floor(uv + skewAmount);
                float unskewAmount = (skewedGridId.x + skewedGridId.y) * UNSKEW_FACTOR_2D;
                float2 cellOriginUnskewed = skewedGridId - unskewAmount;
                
                // Distance vector from the first corner (vertex 0) to our target point
                float2 distToCorner0 = uv - cellOriginUnskewed; 
                // If x > y, we are in the lower-right triangle; otherwise, upper-left.
                float2 corner1Offset = (distToCorner0.x > distToCorner0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
                float2 distToCorner1 = distToCorner0 - corner1Offset + UNSKEW_FACTOR_2D;
                float2 distToCorner2 = distToCorner0 - float2(1.0, 1.0) + (2.0 * UNSKEW_FACTOR_2D);

                // Calculate the random gradient direction for each of the 3 corners
                float2 gradient0 = hash22(skewedGridId) * 2.0 - 1.0;
                float2 gradient1 = hash22(skewedGridId + corner1Offset) * 2.0 - 1.0;
                float2 gradient2 = hash22(skewedGridId + float2(1.0, 1.0)) * 2.0 - 1.0;

                // Calculate the radial falloff intensity for each corner
                float3 squaredDistances = float3(dot(distToCorner0, distToCorner0), 
                                                dot(distToCorner1, distToCorner1), 
                                                dot(distToCorner2, distToCorner2));
                                             
                float3 falloffWeights = max(0.5 - squaredDistances, 0.0);
                float3 smoothFalloff = falloffWeights * falloffWeights * falloffWeights * falloffWeights; // Power of 4

                // Multiply the falloff by the dot product of the gradient and distance vector
                float3 cornerContributions = smoothFalloff * float3(dot(gradient0, distToCorner0), 
                                                                    dot(gradient1, distToCorner1), 
                                                                    dot(gradient2, distToCorner2));

                // Sum up noise contributions and scale to fit a clean [-1, 1] range
                return 70.0 * (cornerContributions.x + cornerContributions.y + cornerContributions.z);
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                float noise = simplexNoise(pos2D) * 0.5 + 0.5;

                float3 color = noise.xxx;

                return float4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
