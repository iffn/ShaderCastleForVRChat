Shader "ShaderCastle/Tutorials/GrabPass/BasicGrabPass"
{
    SubShader
    {
        Tags { "Queue"="Transparent+500" "RenderType"="Transparent" } //Queue Transparent+500 = 3500. Makes sure that it renders after everything else in the world.

        GrabPass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture;

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
                half3 color = tex2D(_GrabTexture, i.uv);
                
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
