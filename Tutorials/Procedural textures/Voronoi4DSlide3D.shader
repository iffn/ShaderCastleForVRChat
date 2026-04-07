Shader "ShaderCastle/ProceduralTextures/Voronoi4DSlide3D"
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

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // Fragment function

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

            float3 voronoi4D(float4 position) {
                float4 baseCell = floor(position);

                float closestDistance = 8.0;
                float secondClosestDistance = 8.0;
                float closestSeed = 0;
                float4 closestCell;

                [unroll]
                for(int w = -1; w <= 1; w++) {
                    for(int z = -1; z <= 1; z++) {
                        for(int y = -1; y <= 1; y++) {
                            [unroll]
                            for(int x = -1; x <= 1; x++) {
                                float4 cellOffset = float4(x, y, z, w);
                                float4 cell = baseCell + cellOffset;
                                float seed = hash11(hash11(hash11(cell.x) + cell.y) + cell.z) + cell.w;
                                
                                float4 randomOffset = float4(
                                    hash11(seed + 123.123), 
                                    hash11(seed + 456.456),
                                    hash11(seed + 789.789),
                                    hash11(seed + 444.444)
                                );

                                float4 cellPosition = cell + randomOffset;
                                float4 distanceToCell = cellPosition - position;
                                float distance = length(distanceToCell);

                                if(distance < closestDistance) {
                                    secondClosestDistance = closestDistance;
                                    closestDistance = distance;
                                    closestSeed = seed;
                                    closestCell = cell;
                                } else if (distance < secondClosestDistance) {
                                    secondClosestDistance = distance;
                                }
                            }
                        }
                    }
                }

                float edgeDist = secondClosestDistance - closestDistance;
                
                float cellID = hash11(closestSeed);

                return float3(closestDistance, cellID, edgeDist);
            }
            
            fixed4 frag (v2f i) : SV_Target {
                float3 pos3D = i.vertex.xyz;
                pos3D.z += _Time;
                pos3D *= _zoom;

                float4 lookup = float4(pos3D, _Time.y);

                fixed3 color = voronoi4D(lookup);

                return fixed4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
