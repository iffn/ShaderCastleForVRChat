Shader "ShaderCastle/Tutorials/ProceduralTextures/Voronoi2D"
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
                uint h = asuint(p);

                h ^= 0x27D4EB2DU; 

                h = h * 1103515245U + 12345U;
                h ^= (h >> 16);
                h *= 0x85ebca6bU;
                h ^= (h >> 13);
                h *= 0xc2b2ae35U;
                h ^= (h >> 16);

                return float(h & 0x00ffffffu) / float(0x01000000u);
            }

            float3 voronoi2D(float2 position) {
                float2 baseCell = floor(position);

                float closestDistance = 8.0;
                float secondClosestDistance = 8.0;
                float closestSeed = 0;

                [unroll]
                for(int y = -1; y <= 1; y++) {
                    [unroll]
                    for(int x = -1; x <= 1; x++) {
                        float2 cellOffset = float2(x, y);
                        float2 cell = baseCell + cellOffset;
                        float seed = hash11(cell.x) + cell.y;
                        
                        float2 randomOffset = float2(
                            hash11(seed + 111.111),
                            hash11(seed + 222.222)
                        );

                        float2 cellPosition = cell + randomOffset;
                        float2 distanceToCell = cellPosition - position;
                        float distance = length(distanceToCell);

                        if(distance < closestDistance) {
                            secondClosestDistance = closestDistance;
                            closestDistance = distance;
                            closestSeed = seed;
                        } else if (distance < secondClosestDistance) {
                            secondClosestDistance = distance;
                        }
                    }
                }

                float edgeDist = secondClosestDistance - closestDistance;
                
                float cellID = hash11(closestSeed);

                return float3(closestDistance, cellID, edgeDist);
            }
            
            half4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                half3 color = voronoi2D(pos2D);
                return half4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
