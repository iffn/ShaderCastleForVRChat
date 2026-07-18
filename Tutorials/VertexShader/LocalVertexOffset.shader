Shader "ShaderCastle/Tutorials/VertexShader/LocalVertexOffset"
{
    SubShader
    {
        Pass
        {
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
                v.vertex *= sin(_Time.y) * 0.5 + 0.5; // Modifying the mesh position before transforming it
                o.pos = UnityObjectToClipPos(v.vertex);
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
