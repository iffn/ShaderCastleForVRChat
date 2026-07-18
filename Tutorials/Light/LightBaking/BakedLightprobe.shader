Shader "ShaderCastle/Tutorials/Light/LightProbes"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {  
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                float3 worldNormal = normalize(i.worldNormal);

                float3 surfaceIrradiance = ShadeSH9(float4(worldNormal, 1.0)); // ShadeSH9 expects a float4 where the xyz is the normal and w is 1.0
                
                float3 BRDFLightFactor = _albedo.rgb;
                float3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                float3 surfaceLight = emissiveLight + reflectedLight;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}