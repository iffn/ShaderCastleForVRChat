Shader "ShaderCastle/Tutorials/VertexShader/Wireframe"
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

            // Order: Mesh -> Vertex -> Geometry -> Fragment

            // Mesh data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Vertex to Geometry transfer data
            struct v2g {
                float4 pos : SV_POSITION;
            };
            
            // Vertex function
            v2g vert (appdata v) {
                v2g o;
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            // Geometry to fragment transfer data
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
            };
            
            // Geometry function
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
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
            half4 frag (g2f i) : SV_Target {
                float closest = min(i.barycentric.x, min(i.barycentric.y, i.barycentric.z));
                float WireframeWith = 0.02;
                float frame = step(closest, WireframeWith);

                half3 frameColor = half3(0.0, 0.0, 0.0); // Black
                half3 color = half3(1.0, 0.0, 0.0); // Red

                color = lerp(color, frameColor, frame);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
