Shader "ShaderCastle/Tutorials/VertexShader/VerticalBillboard"
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

                float3 worldCenter = float3(objectToWorld._m03, objectToWorld._m13, objectToWorld._m23);
                
                float scaleX = length(float3(objectToWorld._m00, objectToWorld._m10, objectToWorld._m20));
                float scaleY = length(float3(objectToWorld._m01, objectToWorld._m11, objectToWorld._m21));

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

            half4 frag () : SV_Target {
                half3 color = half3(1.0, 0.0, 0.0); // Red
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
