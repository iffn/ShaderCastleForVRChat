Shader "ShaderCastle/MathFunctions/MandelbrotFunction"
{
    Properties
    {
        _scale ("Scale", float) = 2
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _scale;
            float _a;
            float _b;
            float _c;
            float _d;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                // Preparation
                float2 uv = i.uv;
                float2 coordinate = (uv * 2 - 1) * _scale;
                fixed3 col = fixed3(1,1,1);

                // Mandelbrot Variables
                float2 z = float2(0, 0);
                float iterations = 0;
                float maxIterations = 128; // Higher = more detail
                
                // The Mandelbrot Loop
                for (int j = 0; j < 128; j++) 
                {
                    // Complex math: z = z^2 + c
                    float x = (z.x * z.x - z.y * z.y) + coordinate.x;
                    float y = (2.0 * z.x * z.y) + coordinate.y;
                    z = float2(x, y);

                    // Check if the point escaped
                    if (dot(z, z) > 4.0)
                        break;
                    
                    iterations++;
                }

                // Normalizing iterations for the lerp
                // 0 = inside the set (black), 1 = outside the set (white)
                float function = iterations / maxIterations;

                // Plotting the function
                col = lerp(col, fixed3(0,0,0), function);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
