Shader "ShaderCastle/VertexShader/VertexSpin"
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
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;

                float xOffset = v.vertex.x;
                float zOffset = v.vertex.z;
                float sinTime = sin(_Time.y);
                float cosTime = cos(_Time.y);

                v.vertex.x = xOffset * cosTime + zOffset * sinTime;
                v.vertex.z = -xOffset * sinTime + zOffset * cosTime;
                
                o.pos = UnityObjectToClipPos(v.vertex); // Basic object to clip space transformation
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
