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

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                fixed3 col = fixed3(i.localPos.xyz + 0.5);
                col = pow(col, 2.2);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
