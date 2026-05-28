Shader "ShaderCastle/Tutorials/Light/LambertLightDirection"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _world_light_direction;

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
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                half3 BRDFLightFactor = half3(0.9, 0.2, 0.2);

                float3 normalized_world_light_direction = normalize(_world_light_direction);
                half NdotL = dot(worldNormal, normalized_world_light_direction);
                half3 randiantIntensity = half3(1.0, 1.0, 1.0);
                half3 surfaceIrradiance = randiantIntensity * NdotL;
                
                half3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + reflectedLight;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}