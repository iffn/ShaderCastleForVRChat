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
            
            float3 hsv2rgb(float3 hsv) {
                float3 p = abs(frac(hsv.xxx + K_HSV.xyz) * 6.0 - K_HSV.www);
                float3 rgb = hsv.z * lerp(K_HSV.xxx, saturate(p - K_HSV.xxx), hsv.y);
                return rgb;
            }

            float3 hsv2rgbSlow(float3 hsv)
            {
                float hue = hsv.r;
                float saturation = hsv.g;
                float value = hsv.b;

                float3 phaseOffsets = hue + K_HSV.xyz;
                float3 rawHueTriangles = abs(frac(phaseOffsets) * 6.0 - K_HSV.www);
                float3 baseColor = saturate(rawHueTriangles - K_HSV.xxx);

                float3 white = float3(1.0, 1.0, 1.0);
                float3 colorLerpedWithWhite = lerp(white, baseColor, saturation);

                float3 finalColorLerpedWithBlack = colorLerpedWithWhite * value;

                return finalColorLerpedWithBlack;
            }

            float4 frag (v2f i) : SV_Target {
                float3 hsv = float3(i.localPos.xyz + 0.5);
                float3 color = hsv2rgb(hsv);

                #ifndef UNITY_COLORSPACE_GAMMA
                    color = pow(color, 2.2); 
                #endif
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
