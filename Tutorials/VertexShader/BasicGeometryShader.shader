Shader "ShaderCastle/Tutorials/VertexShader/BasicGeometryShader"
{
    SubShader
    {
        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma target 4.0

            #include "UnityCG.cginc"

            // Order: Mesh -> Vertex -> Geometry -> Fragment

            // Mesh data
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Vertex to Geometry transfer data
            struct v2g
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };
            
            // Vertex function
            v2g vert (appdata v)
            {
                v2g o;
                o.pos = v.vertex;
                o.normal = v.normal;
                return o;
            }

            // Geometry to fragment transfer data
            struct g2f
            {
                float4 pos : SV_POSITION;
            };

            // Geometry function
            [maxvertexcount(4)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                // Goal: Ignore the triangle and place 1 quad sticking out of the triangle instead

                // World-space triangle corners
                float3 A = input[0].pos;
                float3 B = input[1].pos;
                float3 C = input[2].pos;

                // Triangle center and normal
                float3 triCenter = (A + B + C) * 0.333333333333;
                float3 edge1 = B - A;
                float3 edge2 = C - A;
                float3 triNormal = normalize(cross(edge1, edge2));

                // Two directions of the quad
                float3 right = (A - triCenter) * 0.5;
                float3 up = triNormal * length(right);

                // Calculate corner points
                float3 v0 = triCenter - right;
                float3 v1 = triCenter + right;
                float3 v2 = triCenter + up - right;
                float3 v3 = triCenter + up + right;
                
                // Emit 4 corners of the connected quad
                g2f o0;
                o0.pos = UnityObjectToClipPos(v0);
                triStream.Append(o0);
                
                g2f o1;
                o1.pos = UnityObjectToClipPos(v1);
                triStream.Append(o1);
                                    
                g2f o2;
                o2.pos = UnityObjectToClipPos(v2);
                triStream.Append(o2);

                g2f o4;
                o4.pos = UnityObjectToClipPos(v3);
                triStream.Append(o4);
            }

            // Fragment function
            half4 frag(g2f i) : SV_Target
            {
                half3 color = half3(0.0, 0.0, 1.0); // Blue
                return half4(color, 1.0);
            }

            ENDCG
        }
    }
}