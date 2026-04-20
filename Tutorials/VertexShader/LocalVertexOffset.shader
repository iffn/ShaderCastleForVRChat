Shader "ShaderCastle/Tutorials/VertexShader/LocalVertexOffset"
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
                v.vertex *= sin(_Time.y) * 0.5 + 0.5;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag () : SV_Target {
                half3 color = half3(1.0, 0.0, 0.0); // Red
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
