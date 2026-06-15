Shader "ShaderCastle/Tutorials/Light/BlinnPhongModel"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Directional light color", Color) = (1,1,1,1)
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
                float3 lightDirection = normalize(_worldLightDirection);

                // All vectors are normalized and point away from the surface
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightVector + viewVector);

                half3 emissiveLight = half3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                half3 radiantIntensity = _directionalLightColor;
                half NdotL01 = saturate(dot(worldNormal, lightVector));
                half3 surfaceIrradianceDirectionalLight = radiantIntensity * NdotL01;
                
                // Blinn-Phong model:
                float NdotH = saturate(dot(worldNormal, halfVector));
                float specularFactor = pow(NdotH, _glossiness);
                half3 specularLight = _directionalLightColor * specularFactor;

                half3 ambientLight = _albedo * _ambientLightColor;
                half3 diffuseLight = _albedo * surfaceIrradianceDirectionalLight;
                half3 surfaceRadiance = ambientLight + diffuseLight + specularLight;

                half3 surfaceLight = emissiveLight + surfaceRadiance;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}