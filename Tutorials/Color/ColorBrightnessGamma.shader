Shader "ShaderCastle/Tutorials/Color/ColorRGBBoxGamma"
{
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 localPos : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.localPos = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                half3 color = half3(i.localPos.xxx + 0.5);

                #ifndef UNITY_COLORSPACE_GAMMA
                    color = pow(color, 2.2); 
                #endif

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
