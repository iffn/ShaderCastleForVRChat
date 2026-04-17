Shader "ShaderCastle/Tutorial/DitheredTransparency4x4"
{
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;
                float distanceToCenter = length(uv - float2(0.5, 0.5));
                float alpha = saturate(1.0 - distanceToCenter * 2.0);

                // 4x4 Bayer dithering matrix
                float4x4 ditherMatrix = float4x4(
                    0.0625, 0.5625, 0.1875, 0.6875,
                    0.8125, 0.3125, 0.9375, 0.4375,
                    0.25,   0.75,   0.125,  0.625,
                    1.0,    0.5,    0.875,  0.375
                );

                uint2 pixelPos = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;
                float threshold = ditherMatrix[pixelPos.x % 4][pixelPos.y % 4];

                clip(alpha - threshold);

                fixed3 color = fixed3(1.0, 1.0, 1.0);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}