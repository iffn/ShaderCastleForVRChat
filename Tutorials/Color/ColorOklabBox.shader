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

            half3 oklab2rgb(half3 lab) {
                float3 lms;
                lms.x = lab.x + 0.3963377774f * lab.y + 0.2158037573f * lab.z;
                lms.y = lab.x - 0.1055613458f * lab.y - 0.0638541728f * lab.z;
                lms.z = lab.x - 0.0894841775f * lab.y - 1.2914855480f * lab.z;

                float3 lms_linear = lms * lms * lms;

                half3 rgb;
                rgb.r = +4.0767416621f * lms_linear.x - 3.3077115913f * lms_linear.y + 0.2309699292f * lms_linear.z;
                rgb.g = -1.2684380046f * lms_linear.x + 2.6097574011f * lms_linear.y - 0.3413193965f * lms_linear.z;
                rgb.b = -0.0041960863f * lms_linear.x - 0.7034186147f * lms_linear.y + 1.7076147010f * lms_linear.z;

                return rgb;
            }

            half4 frag (v2f i) : SV_Target {
                float3 coordinate01 = half3(i.localPos.xyz + 0.5);
                half3 oklab;
                oklab.x = coordinate01.z;
                oklab.y = (coordinate01.y - 0.5) * 0.8;
                oklab.z = (coordinate01.x - 0.5) * 0.8;
                float3 color = oklab2rgb(oklab);
                
                #ifndef UNITY_COLORSPACE_GAMMA
                    color = pow(color, 2.2); 
                #endif

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
