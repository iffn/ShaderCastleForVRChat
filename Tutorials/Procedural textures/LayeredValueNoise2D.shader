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

            float hash21(float2 p) {
                return hash11(hash11(p.x) + p.y);
            }

            float valueNoise(float2 uv) {
                // Base parameters
				float2 i = floor(uv);
				float2 f = frac(uv);
                float2 u = f*f*(3.0-2.0*f); // Smoothstep between 0...1

                // Random weights
                float a = hash21(i + float2(0.0, 0.0));
                float b = hash21(i + float2(1.0, 0.0));
                float c = hash21(i + float2(0.0, 1.0));
                float d = hash21(i + float2(1.0, 1.0));

                // Bilinear interpolation
				float bottom = lerp(a, b, u.x);
				float top = lerp(c, d, u.x);
				return lerp(bottom, top, u.y);
			}
            
            fixed4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;
                
                // Based on https://www.shadertoy.com/view/lsf3WH
                float2x2 octaveTransform = float2x2(
                     1.6,  1.2, 
                    -1.2,  1.6);
                    
                float noise = 0.5 * valueNoise(pos2D);
                
                pos2D = mul(octaveTransform, pos2D);
                
                noise += 0.25 * valueNoise(pos2D);
                
                pos2D = mul(octaveTransform, pos2D);
                
                noise += 0.125 * valueNoise(pos2D);

                fixed3 color = noise.xxx;

                return fixed4(color.rgb, 1.0);
            }

            ENDCG
        }
    }
}
