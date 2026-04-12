Shader "ShaderCastle/VertexShader/LocalVertexOffset"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

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

                float viewScaleX = length(float3(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20));
                float viewScaleY = length(float3(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21));
                float4 viewPosition = float4(v.vertex.x * viewScaleX, v.vertex.y * viewScaleY, 0, 0);

                float4 viewSpaceCenter = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
                float4 viewPos = viewSpaceCenter + viewPosition;

                o.pos = mul(UNITY_MATRIX_P, viewPos);
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
