Shader "ShaderCastle/Tutorials/VertexShader/CullFront"
{
    SubShader
    {
        Pass
        {
            Cull Front // Cull = 'Skip drawing' when looking from this side
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

                float xOffset = v.vertex.x;
                v.vertex.x = xOffset * sin(_Time.y);
                v.vertex.z = xOffset * cos(_Time.y);

                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag () : SV_Target {
                float3 color = float3(1.0, 0.0, 0.0);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
