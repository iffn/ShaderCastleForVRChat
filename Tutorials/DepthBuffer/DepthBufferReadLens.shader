Shader "ShaderCastle/Tutorials/DepthBuffer/DepthBufferReadLens"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;

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
                float2 screenUV = i.pos.xy / _ScreenParams.xy;
                half3 color = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
