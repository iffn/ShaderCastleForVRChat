Shader "ShaderCastle/Basics/ReflectionProbe"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"//
            #include "UnityStandardBRDF.cginc"
            #include "UnityPBSLighting.cginc"

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectDir = reflect(-viewDir, worldNormal);
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, 0);

                half3 reflection = DecodeHDR(rgbm, unity_SpecCube0_HDR);

                return fixed4(reflection, 1);
            }
            ENDCG
        }
    }
}
