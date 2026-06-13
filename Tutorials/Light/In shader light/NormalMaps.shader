Shader "ShaderCastle/Tutorials/Light/NormalMaps"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,0)
        _directionalLightColor ("Directional light color", Color) = (1,1,1,1)
        _glossiness ("Glossiness", float) = 32
        _ambientLightColor ("Ambient light color", Color) = (1,1,1,1)
        _albedo ("Albedo texture", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
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
            float _glossiness;
            half3 _ambientLightColor;
            
            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; // Required for TBN (Tangent, Bitangent Normal) matrix
                float2 uv : TEXCOORD0; // Required for texture mapping
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                // Surface directions for correct normal map projection
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);

                // All vectors are normalized and point away from the surface
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(lightVector + viewVector);
                
                // World normal with normal map
                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal); // Unity macro to correctly handle the decompression this version of Unity uses
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal)); // TBN matrix to transform normal from Tangent Space to World Space
                float3 worldNormal = normalize(mul(tangentNormal, tbn));
                
                half3 emissiveLight = half3(0.0, 0.0, 0.0);
                
                // Light hitting the surface:
                half NdotL = dot(worldNormal, lightVector);
                half3 radiantIntensity = _directionalLightColor;
                half3 surfaceIrradianceDirectionalLight = radiantIntensity * saturate(NdotL);
                
                // Blinn-Phong model:
                float NdotH = saturate(dot(worldNormal, halfVector));
                float specularFactor = pow(NdotH, _glossiness);
                half3 specularLight = _directionalLightColor * specularFactor;
                
                half3 albedo = tex2D(_albedo, i.uv).rgb;
                half3 ambientLight = albedo * _ambientLightColor;
                half3 diffuseLight = albedo * surfaceIrradianceDirectionalLight;
                half3 surfaceRadiance = ambientLight + diffuseLight + specularLight;

                half3 surfaceLight = emissiveLight + surfaceRadiance;

                return half4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}