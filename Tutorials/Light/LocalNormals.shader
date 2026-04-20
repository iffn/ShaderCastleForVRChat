Shader "ShaderCastle/Tutorials/Light/LocalNormals"
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
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                half3 color = half3(i.normal);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
