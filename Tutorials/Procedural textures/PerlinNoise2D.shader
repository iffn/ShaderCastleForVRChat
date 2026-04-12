Shader "ShaderCastle/ProceduralTextures/PerlinNoise2D"
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

            float hash21(float2 p) {
                return hash11(hash11(p.x) + p.y);
            }

            float2 hash22(float2 p)
            {
                float a = hash11(hash11(p.x) + p.y);
                float b = hash11(a);
                return float2(a, b);
            }

            float perlinNoise(float2 uv) {
                // Base parameters
				float2 i = floor(uv);
				float2 f = frac(uv);
                float2 u = f*f*(3.0-2.0*f); // Smoothstep between 0...1

                // Random gradients
                float2 ga = hash22(i + float2(0.0, 0.0)) * 2.0 - 1.0;
                float2 gb = hash22(i + float2(1.0, 0.0)) * 2.0 - 1.0;
                float2 gc = hash22(i + float2(0.0, 1.0)) * 2.0 - 1.0;
                float2 gd = hash22(i + float2(1.0, 1.0)) * 2.0 - 1.0;

                // Distnace to center
                float2 da = f - float2(0.0, 0.0);
                float2 db = f - float2(1.0, 0.0);
                float2 dc = f - float2(0.0, 1.0);
                float2 dd = f - float2(1.0, 1.0);

                // Dot products as weights
                float va = dot(ga, da);
                float vb = dot(gb, db);
                float vc = dot(gc, dc);
                float vd = dot(gd, dd);

                // Bilinear interpolation
				float bottom = lerp(va, vb, u.x);
				float top = lerp(vc, vd, u.x);
				return lerp(bottom, top, u.y);
			}
            
            fixed4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                float noise = perlinNoise(pos2D) * 0.5 + 0.5;

                fixed3 color = noise.xxx;

                return fixed4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
