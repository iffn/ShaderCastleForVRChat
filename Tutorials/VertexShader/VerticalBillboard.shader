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

                float3 worldCenter = float3(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23);
                
                float scaleX = length(float3(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20));
                float scaleY = length(float3(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21));

                float3 lookDir = _WorldSpaceCameraPos - worldCenter;
                lookDir.y = 0;
                lookDir = normalize(lookDir);

                float3 worldUp = float3(0, 1, 0);
                float3 worldRight = normalize(cross(lookDir, worldUp));

                float3 worldPos = worldCenter 
                                + worldRight * v.vertex.x * scaleX 
                                + worldUp * v.vertex.y * scaleY;

                o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));

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
