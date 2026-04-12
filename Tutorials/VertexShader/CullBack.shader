Shader "ShaderCastle/VertexShader/CullBack"
{
    SubShader
    {
        Pass
        {
            Cull Back
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
                
                // Simple spinning quad
                float xOffset = v.vertex.x;
                v.vertex.x = xOffset * sin(_Time.y);
                v.vertex.z = xOffset * cos(_Time.y);

                o.pos = UnityObjectToClipPos(v.vertex);
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
