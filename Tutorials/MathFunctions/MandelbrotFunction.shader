Shader "ShaderCastle/MathFunctions/MandelbrotFunction"
{
    Properties
    {
        _scale ("Scale", float) = 2
        _base ("Base", color) = (0.1, 0.1, 0.1, 1)
        _shape ("Shape", color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _scale;
            fixed4 _base;
            fixed4 _shape;

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
                uv.x -= 0.2;
                float2 coordinate = (uv * 2 - 1) * _scale;

                // Mandelbrot Variables
                float2 z = float2(0, 0);
                float iterations = 0;
                float maxIterations = 128; // Higher = more detail
                
                // The Mandelbrot Loop
                for (int j = 0; j < maxIterations; j++) 
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
                float function = iterations / maxIterations;

                // Plotting the function
                function = pow(function, 2.2);

                fixed3 col = lerp(_base, _shape, function);
                
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
