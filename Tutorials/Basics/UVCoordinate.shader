Shader "ShaderCastle/Tutorials/Basics/UVCoordinate"
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

            // Fragment function
            half4 frag (v2f i) : SV_Target {
                half3 color = half3(i.uv, 0.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
