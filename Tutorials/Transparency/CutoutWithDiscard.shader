Shader "ShaderCastle/Tutorials/Transparency/CutoutWithClip"
{
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                float2 uv = i.uv;

                float distanceToCenter = length(uv - float2(0.5, 0.5));

                if(distanceToCenter > 0.5)
                    discard;
                
                half3 color = half3(1.0, 1.0, 1.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
