Shader "ShaderCastle/Light/BRDF"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _albedo ("Albedo", color) = (1,1,1,1)
        _light_color ("Light color", color) = (1,1,1,1)
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
            #pragma target 3.0
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
                float3 normal = normalize(i.normal);
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 specularTint = _albedo * _metallic;
				float oneMinusReflectivity;
                float3 albedo = DiffuseAndSpecularFromMetallic(_albedo.rgb, _metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = _light_color;
                light.dir = _world_light_direction;
                light.ndotl = saturate(dot(worldNormal, normalized_world_light_direction));

                UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

                return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _smoothness,
					worldNormal, viewDir,
					light, indirectLight
				);
            }
            ENDCG
        }
    }
}