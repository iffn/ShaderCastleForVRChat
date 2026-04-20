Shader "ShaderCastle/Tutorials/Basics/JustRed"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert // The vertex function is called vert
            #pragma fragment frag // The fragment funciton is called frag

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Vertex to fragment transfer data
            struct v2f {
                float4 pos : SV_POSITION;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // Basic object to clip space transformation
                return o;
            }

            // Fragment function
            half4 frag () : SV_Target {
                half3 color = half3(1.0, 0.0, 0.0); // Red
                return half4(color, 1.0); // 1.0 on alpha channel, default for opaque
            }
            ENDCG
        }
    }
}
