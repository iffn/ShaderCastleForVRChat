Shader "ShaderCastle/Basics/ColorHSVCylinderGamma"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float4 localPos : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.localPos = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            static const float4 K_HSV = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            fixed3 hsv2rgb(fixed3 hsv) {
                float3 p = abs(frac(hsv.xxx + K_HSV.xyz) * 6.0 - K_HSV.www);
                fixed3 rgb = hsv.z * lerp(K_HSV.xxx, saturate(p - K_HSV.xxx), hsv.y);
                return rgb;
            }
            
            static const float4 K_RGB = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            fixed3 rgb2hsv(fixed3 rgb) {
                float4 p = lerp(float4(rgb.bg, K_RGB.wz), float4(rgb.gb, K_RGB.xy), step(rgb.b, rgb.g));
                float4 q = lerp(float4(p.xyw, rgb.r), float4(rgb.r, p.yzx), step(p.x, rgb.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10; // Small epsilon to prevent division by zero
                fixed3 hsv = fixed3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
                return hsv;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                fixed angle = atan2(i.localPos.x, i.localPos.z) * 0.15915494309;
                fixed distance = length(i.localPos.xz) * 2;
                fixed height = i.localPos.y * 0.5 + 0.5;
                fixed3 hsv = fixed3(angle, distance, height);
                float3 col = hsv2rgb(hsv);
                col = pow(col, 2.2);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
