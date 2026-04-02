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

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                fixed angle = atan2(i.localPos.x, i.localPos.z) * 0.15915494309;
                fixed distance = length(i.localPos.xz) * 2;
                fixed height = i.localPos.y * 0.5 + 0.5;
                fixed3 hsv = fixed3(angle, distance, height);
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
                float3 col = hsv.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
                col = pow(col, 2.2);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
