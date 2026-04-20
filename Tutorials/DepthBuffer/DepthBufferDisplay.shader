Shader "ShaderCastle/Tutorials/DepthBuffer/DepthBufferDisplay"
{
    Properties
    {
        _DepthTex ("Depth texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _DepthTex; // Access to the depth buffer

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
                uv.x = 1-uv.x;
                half3 color = tex2D(_DepthTex, uv);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
