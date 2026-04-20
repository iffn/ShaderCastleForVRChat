Shader "ShaderCastle/Tutorials/Light/WorldNormals"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" // Required for UnityObjectToWorldNormal

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized

                return o;
            }

            // Fragment function
            half4 frag (v2f i) : SV_Target {
                half3 color = half3(i.worldNormal);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
