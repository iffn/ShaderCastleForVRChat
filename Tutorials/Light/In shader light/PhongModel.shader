Shader "ShaderCastle/Tutorials/Light/LambertLightDirection"
{
    Properties
    {
        _worldLightDirection ("World light direciton", Vector) = (1,1,1,0)
        _directionalLightColor ("Light color", Color) = (1,1,1,1)
        _albedo ("Albedo", Color) = (1,1,1,1)
        _glossiness ("Glossiness", float) = 32
        _ambientLightColor ("Ambient light color", Color) = (1,1,1,1)
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
            float _glossiness;
            half3 _specularColor;
            half3 _ambientLightColor;

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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDirection = normalize(_worldLightDirection);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                half NdotL = saturate(dot(worldNormal, lightVector));
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL;
                
                // Phong model:
                float3 reflectVector = reflect(lightDirection, worldNormal); // Built in function to get the surface reflection vector
                float RdotV = saturate(dot(reflectVector, viewVector));
                float specularFactor = pow(RdotV, _glossiness);
                half3 specularComponent = _directionalLightColor * specularFactor;

                half3 ambientLight = _albedo * _ambientLightColor;
                half3 diffuseLight = _albedo * surfaceIrradianceDirectionalLight;
                half3 specularLight = specularComponent * surfaceIrradianceDirectionalLight;
                half3 surfaceRadiance = ambientLight + diffuseLight + specularLight;

                half3 emittedLight = emissiveLight + surfaceRadiance;

                return half4(emittedLight, 1.0);
            }
            ENDCG
        }
    }
}