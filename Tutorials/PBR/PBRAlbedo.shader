Shader "ShaderCastle/Light/PBRAlbedo"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
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
            sampler2D _albedo;
            float4 _albedo_ST; // Required to get the sampler state (-> _ST)
            half4 _light_color;
            half4 _ambient_light_color;
            float _smoothness;
            float _metallic;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                o.uv = TRANSFORM_TEX(v.uv, _albedo); // Includes tiling and offset

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 normal = normalize(i.normal);
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                fixed4 color = tex2D(_albedo, i.uv);

                float3 specularTint = color * _metallic;
				float oneMinusReflectivity;
                float3 albedo = DiffuseAndSpecularFromMetallic(color.rgb, _metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = _light_color;
                light.dir = _world_light_direction;
                light.ndotl = saturate(dot(worldNormal, normalized_world_light_direction));

                float3 reflectDir = reflect(-viewDir, worldNormal);
                float perceptualRoughness = 1.0 - _smoothness;
                float mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mip);
                half3 indirectSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                
                UnityIndirect indirectLight;
                indirectLight.diffuse = _ambient_light_color;
                indirectLight.specular = indirectSpecular;

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