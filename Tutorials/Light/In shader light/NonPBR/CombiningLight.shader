Shader "ShaderCastle/Tutorials/Light/CombiningLights"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Directional light color", Color) = (1,1,1,1)
        _albedo ("Albedo", Color) = (1,1,1,1)
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
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
                half3 radiantIntensity = _directionalLightColor;
                half NdotL01 = saturate(dot(worldNormal, lightVector));
                half3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL01;
                half3 BRDFLightFactor = _albedo; // Simplified model: The light gets reflected in all directions equally.
                half3 surfaceRadianceDirectionalLight = BRDFLightFactor * surfaceIrradianceDirectionalLight; // Usualy, the BRDF factor depends on the different vectors

                half3 surfaceIrradianceAmbientLight = _ambientLightColor;
                half3 surfaceRadianceAmbientLight = _albedo * _ambientLightColor;

                half3 surfaceRadiance = surfaceRadianceDirectionalLight + surfaceRadianceAmbientLight; // The light values can be summed up
                
                half3 surfaceLight = emissiveLight + surfaceRadiance;
                surfaceLight = saturate(surfaceLight); // The traditional model clamps the values to 0...1

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}