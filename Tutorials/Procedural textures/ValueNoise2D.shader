Shader "ShaderCastle/ProceduralTextures/ValueNoise2D"
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

            float valueNoise(float2 uv) {
				float2 i = floor(uv);
				float2 f = frac(uv);

				float a = hash11(hash11(i.x) + i.y);
				float b = hash11(hash11(i.x + 1.0) + i.y);
				float c = hash11(hash11(i.x) + i.y + 1.0);
				float d = hash11(hash11(i.x + 1.0) + i.y + 1.0);

				float bottom = lerp(a, b, f.x);
				float top = lerp(c, d, f.x);

				return lerp(bottom, top, f.y);
			}
            
            fixed4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                float noise = valueNoise(pos2D);

                fixed3 color = noise.xxx;

                return fixed4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
