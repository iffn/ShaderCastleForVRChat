Shader "ShaderCastle/Tutorials/ProceduralTextures/GridSkew"
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

            float _zoom;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            float stepPattern(float x){
                float y = frac(x * 0.5);
                y -= 0.5;
                y = sign(y);
                y = saturate(y);
                return y;
            }

            float4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                // Simplex Skew Factor for 2D: (sqrt(3.0) - 1.0) / 2.0
                const float F2 = 0.366025403;
                
                // 1. Calculate the skew amount based on the sum of components
                float skew = (pos2D.x + pos2D.y) * F2;
                
                // 2. Add the skew to the original coordinates to warp the space
                float2 skewedPos = pos2D + skew;

                float3 black = float3(0.0, 0.0, 0.0);
                float3 white = float3(1.0, 1.0, 1.0);
                
                // 3. Generate the grid pattern using the skewed coordinates
                float xStep = stepPattern(skewedPos.x);
                float yStep = stepPattern(-skewedPos.y);
                float pattern = abs(xStep - yStep);

                float3 color = lerp(black, white, pattern);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
