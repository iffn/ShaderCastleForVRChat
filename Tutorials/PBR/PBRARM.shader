Shader "ShaderCastle/PBR/PBRARM"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
        [NoScaleOffset][Normal] _normal ("Normal", 2D) = "bump" {}
        [NoScaleOffset]_arm ("ARM", 2D) = "white" {}
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
            half4 _light_color;
            half4 _ambient_light_color;
            sampler2D _albedo;
            float4 _albedo_ST; // Required to get the sampler state (-> _ST)
            sampler2D _normal;
            sampler2D _arm;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
                float2 uv : TEXCOORD5;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                o.uv = TRANSFORM_TEX(v.uv, _albedo); // Includes tiling and offset

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldTangent = normalize(i.worldTangent);
                float3 worldBitangent = normalize(i.worldBitangent);
                float3x3 tbn = float3x3(worldTangent, worldBitangent, worldNormal);
                
                float3 arm = tex2D(_arm, i.uv).rgb;
                float ambientOcclusion = arm.r;
                float roughness = arm.g;
                float metallic = arm.b;

                float3 normalMap = UnpackNormal(tex2D(_normal, i.uv));
                float3 bumpedNormal = normalize(mul(normalMap, tbn));

                float3 normalized_world_light_direction = normalize(_world_light_direction);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                fixed4 color = tex2D(_albedo, i.uv);

                float3 specularTint = color * metallic;
				float oneMinusReflectivity;
                float3 albedo = DiffuseAndSpecularFromMetallic(color.rgb, metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = _light_color;
                light.dir = _world_light_direction;
                light.ndotl = saturate(dot(bumpedNormal, normalized_world_light_direction));

                float3 reflectDir = reflect(-viewDir, bumpedNormal);
                float mip = roughness * UNITY_SPECCUBE_LOD_STEPS;
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mip);
                half3 indirectSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                
                UnityIndirect indirectLight;
                indirectLight.diffuse = _ambient_light_color * ambientOcclusion;
                indirectLight.specular = indirectSpecular * ambientOcclusion;

                return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, 1.0 - roughness,
					bumpedNormal, viewDir,
					light, indirectLight
				);
            }
            ENDCG
        }
    }
}