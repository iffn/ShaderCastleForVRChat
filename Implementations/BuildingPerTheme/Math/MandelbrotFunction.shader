Shader "ShaderCastle/Tutorials/MathFunctions/MandelbrotFunction"
{
    Properties
    {
        _scale ("Scale", range(0, 0.2)) = 0.1
        _offset ("Offset", float) = 0
        _base ("Base", color) = (0.1, 0.1, 0.1, 1.0)
        _shape ("Shape", color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _scale;
            float _offset;
            float4 _base;
            float4 _shape;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                return o;
            }

            float Mandelbrot(float2 lookup)
            {
                // Mandelbrot Variables
                float2 z = float2(0, 0);
                float iterations = 0;
                float maxIterations = 600; // Higher = more detail

                for (int j = 0; j < maxIterations; j++) 
                {
                    // Complex math: z = z^2 + c
                    float x = (z.x * z.x - z.y * z.y) + lookup.x;
                    float y = (2.0 * z.x * z.y) + lookup.y;
                    z = float2(x, y);

                    // Check if the point escaped
                    if (dot(z, z) > 4.0)
                        break;
                    
                    iterations++;
                }

                float returnValue = iterations / maxIterations;
                returnValue = pow(returnValue, 2.2);

                return returnValue;
            }

            float4 frag (v2f i) : SV_Target {
                float3 localPos = i.localPos * _scale;

                float2 lookupCoordinate = float2(-localPos.y + _offset, localPos.x);
                lookupCoordinate += normalize(lookupCoordinate) * localPos.z;

                float function = Mandelbrot(lookupCoordinate);

                float3 color = lerp(_base, _shape, function);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
