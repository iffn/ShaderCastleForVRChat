Shader "ShaderCastle/Tutorials/MathFunctions/AbsFunction"
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

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                // Preparation
                float2 uv = i.uv;
                float2 coordinate = (uv * 2 - 1) * _scale;
                half3 black = half3(0,0,0);
                half3 red = half3(1,0,0);
                half3 grey = half3(0.5, 0.5, 0.5);
                half3 color = half3(1,1,1);
                float halfAxisThickness = 0.01 * _scale;
                float minorAxis = sign(abs(frac(coordinate.x) - 0.5) - (0.5 - halfAxisThickness)) * 0.5 + 0.5;
                color = lerp(color, grey, minorAxis);
                minorAxis = sign(abs(frac(coordinate.y) - 0.5) - (0.5 - halfAxisThickness)) * 0.5 + 0.5;
                color = lerp(color, grey, minorAxis);
                float axis = step(-halfAxisThickness, coordinate.x) * step(coordinate.x, halfAxisThickness);
                color = lerp(color, black, axis);
                axis = step(-halfAxisThickness, coordinate.y) * step(coordinate.y, halfAxisThickness);
                color = lerp(color, black, axis);
                float x = coordinate.x;

                // Function to plot
                float function = abs(x);

                // Plotting the function
                float plotFunction = function - coordinate.y;
                float plot = step(-halfAxisThickness, plotFunction) * step(plotFunction, halfAxisThickness * 2);
                color = lerp(color, red, plot);
                return half4(color, 1);
            }
            ENDCG
        }
    }
}
