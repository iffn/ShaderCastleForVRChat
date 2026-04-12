Shader "ShaderCastle/VertexShader/LocalVertexOffset"
{
    SubShader
    {
        Pass
        {
            Cull front
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
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                v.vertex.x *= sin(_Time.y);
                v.vertex.y *= sin(_Time.y);
                v.vertex.z = 1.0;
                o.pos = v.vertex;
                return o;
            }

            // Fragment function
            fixed4 frag () : SV_Target {
                fixed4 col = fixed4(1, 0, 0, 1); // Red
                return col;
            }
            ENDCG
        }
    }
}
