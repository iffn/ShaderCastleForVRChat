Shader "ShaderCastle/Tutorials/Light/ReflectionProbe"
{
    Properties
    {
        _blurMipMap ("Mip map blur", float) = 0
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

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                float3 reflectVector = reflect(-viewVector, worldNormal);
                float4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVector, _blurMipMap);
                float3 reflection = DecodeHDR(rgbm, unity_SpecCube0_HDR);

                return float4(reflection, 1.0);
            }
            ENDCG
        }
    }
}
