Shader "ShaderCastle/Tutorials/Light/PhongModel"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Directional light color", Color) = (1,1,1,1)
        _albedo ("Albedo", Color) = (1,1,1,1)
        _glossiness ("Glossiness", Float) = 32
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
            float3 _directionalLightColor;
            float3 _albedo;
            float _glossiness;
            float3 _ambientLightColor;

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

            float4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);

                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectVector = reflect(lightDirection, worldNormal); // Built in function to get the surface reflection vector

                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float3 radiantIntensity = _directionalLightColor;
                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL01;
                
                // Phong model:
                float RdotV = saturate(dot(reflectVector, viewVector)); // The Phong model uses the dot product between the reflect and view vector
                float specularFactor = pow(RdotV, _glossiness);
                float3 specularLight = _directionalLightColor * specularFactor; // The highlight has the light color

                float3 ambientLight = _albedo * _ambientLightColor;
                float3 diffuseLight = _albedo * surfaceIrradianceDirectionalLight;
                float3 surfaceRadiance = ambientLight + diffuseLight + specularLight;

                float3 surfaceLight = emissiveLight + surfaceRadiance;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}