Shader "ShaderCastle/Tutorials/Transparency/DitheredTransparency2x2"
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

            half4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;
                float distanceToCenter = length(uv - float2(0.5, 0.5));
                float alpha = 1.0 - distanceToCenter * 2.0;

                // 2x2 Bayer dithering matrix
                float2x2 ditherMatrix = float2x2(
                    0, 0.5,
                    0.75, 0.25
                );

                uint2 pixelPos = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;
                float threshold = ditherMatrix[pixelPos.x % 2][pixelPos.y % 2];

                clip(alpha - threshold);

                half3 color = half3(1.0, 1.0, 1.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}