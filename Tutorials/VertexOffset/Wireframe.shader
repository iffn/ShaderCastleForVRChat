Shader "ShaderCastle/VertexOffset/CullOff"
{
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            
            // Based on https://www.youtube.com/watch?v=ehk8ljz2nHI

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
            };
            
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2f IN[3], inout TriangleStream<g2f> triStream) {
                g2f o;

                o.pos = IN[0].pos;
                o.barycentric = float3(1.0, 0.0, 0.0);
                triStream.Append(o);
                
                o.pos = IN[1].pos;
                o.barycentric = float3(0.0, 1.0, 0.0);
                triStream.Append(o);

                o.pos = IN[2].pos;
                o.barycentric = float3(0.0, 0.0, 1.0);
                triStream.Append(o);
            }

            

            // Fragment function
            fixed4 frag (g2f i) : SV_Target {
                float closest = min(i.barycentric.x, min(i.barycentric.y, i.barycentric.z));
                float WireframeWith = 0.02;
                float frame = step(closest, WireframeWith);

                fixed3 frameColor = fixed3(0.0, 0.0, 0.0); // Black

                fixed3 col = fixed3(1.0, 0.0, 0.0); // Red
                col = lerp(col, frameColor, frame);
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
