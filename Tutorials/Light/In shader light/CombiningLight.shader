Shader "ShaderCastle/Tutorials/Light/LambertLightDirection"
{
    Properties
    {
        _worldLightDirection ("World light direciton", Vector) = (1,1,1,0)
        _directionalLightColor ("Light color", Color) = (1,1,1,1)
        _albedo ("Albedo", Color) = (1,1,1,1)
        _ambientLightColor ("Light color", Color) = (0.2, 0.2, 0.2, 1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _worldLightDirection;
            half3 _directionalLightColor;
            half3 _albedo;
            half3 _ambientLightColor;

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
                float3 lightVector = -normalize(_worldLightDirection);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                half NdotL = saturate(dot(worldNormal, lightVector));
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL;
                half3 surfaceIrradianceAmbientLight = _ambientLightColor;
                half3 surfaceIrradiance = surfaceIrradianceDirectionalLight + surfaceIrradianceAmbientLight;
                
                // How much is reflected:
                half3 BRDFLightFactor = _albedo; // Simplified model: The light gets refelcted in all directions equally.
                half3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                half3 emittedLight = emissiveLight + surfaceRadiance;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}