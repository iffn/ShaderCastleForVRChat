Shader "ShaderCastle/Basics/ReflectionProbe"
{
    Properties
    {
        _blurMipMap ("BlurMipMap", float) = 0
        _reflection_probe_light_multiplier ("Reflection probe light multiplier", color) = (1,1,1,1)
    }
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

            float _blurMipMap;
            half4 _reflection_probe_light_multiplier;

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
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, _blurMipMap);

                half3 reflection = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                reflection *= _reflection_probe_light_multiplier.rgb;

                return fixed4(reflection, 1);
            }
            ENDCG
        }
    }
}
