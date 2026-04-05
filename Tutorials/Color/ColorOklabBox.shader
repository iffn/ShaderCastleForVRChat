Shader "ShaderCastle/Basics/ColorRGBBoxGamma"
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

            fixed3 oklab2rgb(fixed3 lab) {
                float3 lms;
                lms.x = lab.x + 0.3963377774f * lab.y + 0.2158037573f * lab.z;
                lms.y = lab.x - 0.1055613458f * lab.y - 0.0638541728f * lab.z;
                lms.z = lab.x - 0.0894841775f * lab.y - 1.2914855480f * lab.z;

                float3 lms_linear = lms * lms * lms;

                fixed3 rgb;
                rgb.r = +4.0767416621f * lms_linear.x - 3.3077115913f * lms_linear.y + 0.2309699292f * lms_linear.z;
                rgb.g = -1.2684380046f * lms_linear.x + 2.6097574011f * lms_linear.y - 0.3413193965f * lms_linear.z;
                rgb.b = -0.0041960863f * lms_linear.x - 0.7034186147f * lms_linear.y + 1.7076147010f * lms_linear.z;

                return rgb;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                fixed3 coordinate01 = fixed3(i.localPos.xyz + 0.5);
                fixed3 oklab;
                oklab.x = coordinate01.z;
                oklab.y = (coordinate01.y - 0.5) * 0.8;
                oklab.z = (coordinate01.x - 0.5) * 0.8;
                float3 col = oklab2rgb(oklab);
                
                //col = pow(col, 2.2);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
