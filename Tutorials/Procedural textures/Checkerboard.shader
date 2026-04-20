Shader "ShaderCastle/Tutorials/ProceduralTextures/Checkerboard"
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

            half4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;

                pos2D *= _zoom;

                half3 black = (0.0, 0.0, 0.0);
                half3 white = (1.0, 1.0, 1.0);

                
                float xStep = stepPattern(pos2D.x);
                float yStep = stepPattern(-pos2D.y);
                float pattern = abs(xStep - yStep);

                half3 color = lerp(black, white, pattern);

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
