Shader "ShaderCastle/Tutorials/Light/BlinnPhongReflectionProbe"
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
                float3 halfVector = normalize(lightVector + viewVector);

                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float NdotL = dot(worldNormal, lightVector);
                float3 radiantIntensity = _directionalLightColor;
                float3 surfaceIrradianceDirectionalLight = radiantIntensity * saturate(NdotL);
                
                // Blinn-Phong model:
                float NdotH = saturate(dot(worldNormal, halfVector));
                float specularFactor = pow(NdotH, _glossiness);
                float3 specularLight = _directionalLightColor * specularFactor;

                //Reflection probe
                float3 reflectionVector = reflect(-viewVector, worldNormal);
                float mipLevel = (1.0 - saturate(_glossiness / 256.0)) * 6.0; // Use glossiness between between 0...256
                float4 encodedReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionVector, mipLevel);
                float3 environmentReflection = DecodeHDR(encodedReflection, unity_SpecCube0_HDR);

                float3 ambientLight = _albedo * _ambientLightColor;
                float3 diffuseLight = _albedo * surfaceIrradianceDirectionalLight;
                float3 tintedReflection = environmentReflection * _albedo;
                float3 surfaceRadiance = ambientLight + diffuseLight + specularLight + tintedReflection;

                float3 surfaceLight = emissiveLight + surfaceRadiance;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}