Shader "ShaderCastle/Tutorials/Color/ColorHSVCylinderGamma"
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
            
            static const float4 K_RGB = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            half3 rgb2hsv(half3 rgb) {
                float4 p = lerp(float4(rgb.bg, K_RGB.wz), float4(rgb.gb, K_RGB.xy), step(rgb.b, rgb.g));
                float4 q = lerp(float4(p.xyw, rgb.r), float4(rgb.r, p.yzx), step(p.x, rgb.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10; // Small epsilon to prevent division by zero
                half3 hsv = half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
                return hsv;
            }

            half4 frag (v2f i) : SV_Target {
                float angle = atan2(i.localPos.x, i.localPos.z) * 0.15915494309;
                float distance = length(i.localPos.xz) * 2;
                float height = i.localPos.y * 0.5 + 0.5;

                half3 hsv = half3(angle, distance, height);
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
