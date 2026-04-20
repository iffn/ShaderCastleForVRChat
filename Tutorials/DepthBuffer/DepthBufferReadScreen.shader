Shader "ShaderCastle/Tutorials/DepthBuffer/DepthBufferReadScreen"
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
                
                float aspectRatio = _ScreenParams.x / _ScreenParams.y;
                v.vertex.x *= aspectRatio;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                half3 color = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
