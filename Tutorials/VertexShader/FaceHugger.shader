Shader "ShaderCastle/Tutorials/VertexShader/FaceHugger"
{
    SubShader
    {
        Pass
        {
            Cull front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                v.vertex.x *= sin(_Time.y);
                v.vertex.y *= sin(_Time.y);
                v.vertex.z = 1.0; // Setting the z value as close to the camera as possible
                o.pos = v.vertex; // Directly applying the vertex position to the camera space
                return o;
            }

            float4 frag () : SV_Target {
                float3 color = float3(1.0, 0.0, 0.0); // Red
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
