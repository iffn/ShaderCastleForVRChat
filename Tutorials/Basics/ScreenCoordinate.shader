Shader "ShaderCastle/Tutorials/Basics/ScreenCoordinate"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // Fragment function
            half4 frag (v2f i) : SV_Target {
                // i.pos.xy returns the current pixel coordinate of the fragment
                // _ScreenParams.xy is the screen resolution in pixels
                float2 screenUV = i.pos.xy / _ScreenParams.xy;
                half3 color = half3(screenUV, 0.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
