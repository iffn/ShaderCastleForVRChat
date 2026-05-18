Shader "ShaderCastle/Tutorials/Basics/UVCoordinate"
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
                float2 uv : TEXCOORD0; // Access to uv values
            };

            // Vertex to fragment transfer data
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0; // UV transfer data
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; // Directly transfering uv values from mesh to fragment
                return o;
            }

            // Fragment function accessing the UV values
            half4 frag (v2f i) : SV_Target {
                half3 color = half3(i.uv, 0.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
