Shader "ShaderCastle/Light/Metallic"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
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
            half4 _albedo;
            half4 _light_color;
            float _smoothness;
            float _metallic;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);

                float3 specularTint = _albedo * _metallic;
				float oneMinusReflectivity;

                float3 albedo = EnergyConservationBetweenDiffuseAndSpecular(_albedo.rgb, specularTint, oneMinusReflectivity);

                fixed3 diffuse = dot(normalized_world_light_direction, worldNormal);
                diffuse *= albedo;
                diffuse *= oneMinusReflectivity;
                diffuse *= _light_color.rgb;
                diffuse = saturate(diffuse);

                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfVector = normalize(normalized_world_light_direction + viewDir);
                float specular = dot(halfVector, worldNormal);
                specular = saturate(specular);
                specular = pow(specular, _smoothness * 100);
                float3 specularColor = specularTint * _light_color * specular;

                fixed4 color = fixed4(diffuse + specularColor, 1);
                return color;
            }
            ENDCG
        }
    }
}