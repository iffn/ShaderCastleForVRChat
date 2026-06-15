Shader "ShaderCastle/Tutorials/Light/UnityBRDFTextures"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _albedo ("Albedo", 2D) = "white" {}
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
        _arm ("ARM", 2D) = "white" {}
        _ambientLightColor ("Ambient light color", Color) = (0.2, 0.2, 0.2, 1)
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

            float3 _worldLightDirection;
            half4 _directionalLightColor;
            sampler2D _albedo;
            float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _arm;
            half3 _ambientLightColor;
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = normalize(cross(o.worldNormal, o.worldTangent) * v.tangent.w);
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 lightDirection = normalize(_worldLightDirection);
                
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);

                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal);
                float3x3 tbn = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
                float3 worldNormal = normalize(mul(tangentNormal, tbn));
                
                half3 albedo = tex2D(_albedo, i.uv);
                half3 arm = tex2D(_arm, i.uv);
                float ambientOcclusion = arm.r;
                float smoothness = 1 - arm.g;
                float metallic = arm.b;
                
                float3 specularTint = albedo * metallic;
				
                float oneMinusReflectivity;
                float3 unityAlbedo = DiffuseAndSpecularFromMetallic(albedo.rgb, metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = _directionalLightColor;
                light.dir = lightVector;
                light.ndotl = saturate(dot(worldNormal, lightVector));

                float3 reflectDir = reflect(-viewVector, worldNormal);
                float perceptualRoughness = 1.0 - smoothness;
                float mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
                half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mip);
                half3 indirectSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                
                UnityIndirect indirectLight;
                indirectLight.diffuse = _ambientLightColor * ambientOcclusion;
                indirectLight.specular = indirectSpecular * ambientOcclusion;

                return UNITY_BRDF_PBS(
					unityAlbedo,
                    specularTint,
					oneMinusReflectivity,
                    smoothness,
					worldNormal,
                    viewVector,
					light, indirectLight
				);
            }
            ENDCG
        }
    }
}