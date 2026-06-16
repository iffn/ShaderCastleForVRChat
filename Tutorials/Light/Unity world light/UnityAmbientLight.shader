Shader "ShaderCastle/Tutorials/Light/AmbientLight"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // Required for _LightColor0

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
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = normalize(_WorldSpaceLightPos0.xyz);

                float3 lightColor = _LightColor0.rgb;
                half3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                float NdotL = dot(worldNormal, lightVector);
                half3 radiantIntensity = lightColor;
                half3 surfaceIrradiance = radiantIntensity * saturate(NdotL);

                half3 BRDFLightFactor = half3(1.0,1.0,1.0); // White
                half3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                half3 surfaceLight = emissiveLight + surfaceRadiance + ambientLight;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}