Shader "ShaderCastle/MathFunctions/FracFunction"
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
                fixed3 black = fixed3(0,0,0);
                fixed3 red = fixed3(1,0,0);
                fixed3 grey = fixed3(0.5, 0.5, 0.5);
                fixed3 col = fixed3(1,1,1);
                float halfAxisThickness = 0.01 * _scale;
                float minorAxis = sign(abs(frac(coordinate.x) - 0.5) - (0.5 - halfAxisThickness)) * 0.5 + 0.5;
                col = lerp(col, grey, minorAxis);
                minorAxis = sign(abs(frac(coordinate.y) - 0.5) - (0.5 - halfAxisThickness)) * 0.5 + 0.5;
                col = lerp(col, grey, minorAxis);
                float axis = step(-halfAxisThickness, coordinate.x) * step(coordinate.x, halfAxisThickness);
                col = lerp(col, black, axis);
                axis = step(-halfAxisThickness, coordinate.y) * step(coordinate.y, halfAxisThickness);
                col = lerp(col, black, axis);
                float x = coordinate.x;

                // Function to plot
                float function = frac(x);

                // Plotting the function
                float plotFunction = function - coordinate.y;
                float plot = step(-halfAxisThickness, plotFunction) * step(plotFunction, halfAxisThickness * 2);
                col = lerp(col, red, plot);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
