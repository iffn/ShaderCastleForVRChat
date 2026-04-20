Shader "ShaderCastle/Tutorials/Color/ColorRGBBoxGamma"
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
                float4 localPos : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.localPos = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            static const float4 K_HSV = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            
            half3 hsv2rgb(half3 hsv) {
                float3 p = abs(frac(hsv.xxx + K_HSV.xyz) * 6.0 - K_HSV.www);
                half3 rgb = hsv.z * lerp(K_HSV.xxx, saturate(p - K_HSV.xxx), hsv.y);
                return rgb;
            }

            half4 frag (v2f i) : SV_Target {
                half3 hsv = half3(i.localPos.xyz + 0.5);
                float3 color = hsv2rgb(hsv);

                #ifndef UNITY_COLORSPACE_GAMMA
                    color = pow(color, 2.2); 
                #endif
                
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
