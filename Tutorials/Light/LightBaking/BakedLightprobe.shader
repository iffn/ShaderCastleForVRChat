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

            half4 _albedo;

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

            half4 frag (v2f i) : SV_Target {
                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half3 worldNormal = normalize(i.worldNormal);

                half3 surfaceIrradiance = ShadeSH9(half4(worldNormal, 1.0)); // ShadeSH9 expects a float4 where the xyz is the normal and w is 1.0
                
                half3 BRDFLightFactor = _albedo.rgb;
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                half3 surfaceLight = emissiveLight + reflectedLight;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}