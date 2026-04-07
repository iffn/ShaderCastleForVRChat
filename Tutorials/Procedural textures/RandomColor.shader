Shader "ShaderCastle/ProceduralTextures/RandomColor"
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

            float hash21(int2 p, uint salt) {
                uint2 q = asuint(p);
                
                uint h = (q.x * 1597334677U) ^ (q.y * 3812015423U) ^ salt;
                
                h = (h ^ (h >> 16)) * 0x85ebca6bU;
                h = (h ^ (h >> 13)) * 0xc2b2ae35U;
                
                return float(h & 0x00ffffffu) / float(0x01000000u);
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                int2 gridID = int2(floor(pos2D));

                float r = hash21(gridID, 0U);
                float g = hash21(gridID, 123456789U);
                float b = hash21(gridID, 987654321U);

                fixed3 color = fixed3(r, g, b);
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
}
