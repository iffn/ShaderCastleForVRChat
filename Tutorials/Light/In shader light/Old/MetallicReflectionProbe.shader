Shader "ShaderCastle/Tutorials/Light/MetallicReflectionProbe"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _smoothness ("Smoothness", Range(0, 1)) = 0.5
        _metallic ("Metallic", Range(0, 1)) = 0.5
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"

            float3 _world_light_direction;
            half4 _light_color;
            half4 _ambient_light_color;
            half4 _albedo;
            float _smoothness;
            float _metallic;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);

                float3 specularTint = _albedo.rgb * _metallic;
                float oneMinusReflectivity;

                float3 albedo = EnergyConservationBetweenDiffuseAndSpecular(_albedo.rgb, specularTint, oneMinusReflectivity);
                
                half3 ambientLight = albedo * _ambient_light_color;

                half3 diffuse = dot(normalized_world_light_direction, worldNormal);
                diffuse *= albedo;
                diffuse *= oneMinusReflectivity;
                diffuse *= _light_color.rgb;
                diffuse = saturate(diffuse);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectDir = reflect(-viewDir, worldNormal);

                float roughness = 1.0 - _smoothness;
                float mipmapSmoothness = roughness * (1.7 - 0.7 * roughness) * 6.0; // Range from 0 to 7
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mipmapSmoothness);
                half3 indirectSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                indirectSpecular *= specularTint;

                float3 halfVector = normalize(normalized_world_light_direction + viewDir);
                float specular = dot(halfVector, worldNormal);
                specular = saturate(specular);
                specular = pow(specular, _smoothness * 100);
                float3 specularColor = specularTint * _light_color.rgb * specular;

                half3 color = half3(diffuse + specularColor + indirectSpecular + ambientLight);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}