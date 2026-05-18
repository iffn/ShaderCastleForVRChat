Shader "ShaderCastle/Tutorials/VertexShader/Billboard"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;

                float4x4 objectToWorld = unity_ObjectToWorld;

                float viewScaleX = length(float3(objectToWorld._m00, objectToWorld._m10, objectToWorld._m20));
                float viewScaleY = length(float3(objectToWorld._m01, objectToWorld._m11, objectToWorld._m21));
                
                float4 viewPosition = float4(v.vertex.x * viewScaleX, v.vertex.y * viewScaleY, 0, 0);

                float4 viewSpaceCenter = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
                float4 viewPos = viewSpaceCenter + viewPosition;

                o.pos = mul(UNITY_MATRIX_P, viewPos);
                
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
