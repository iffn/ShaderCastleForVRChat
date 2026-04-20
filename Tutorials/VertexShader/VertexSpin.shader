Shader "ShaderCastle/Tutorials/VertexShader/VertexSpin"
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

                float xOffset = v.vertex.x;
                float zOffset = v.vertex.z;
                float sinTime = sin(_Time.y);
                float cosTime = cos(_Time.y);

                v.vertex.x = xOffset * cosTime + zOffset * sinTime;
                v.vertex.z = -xOffset * sinTime + zOffset * cosTime;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag () : SV_Target {
                half3 color = half3(1.0, 0.0, 0.0); // Red
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
