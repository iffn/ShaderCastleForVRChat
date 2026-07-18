Shader "ShaderCastle/Tutorials/Light/UnityBRDFValues"
{
    Properties
    {
        _worldLightDirection ("World light direction", Vector) = (1,1,1,1)
        _directionalLightColor ("Directional light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
        _smoothness ("Smoothness", Range(0, 1)) = 0.5
        _metallic ("Metallic", Range(0, 1)) = 0.5
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
            float4 _directionalLightColor;
            float4 _albedo;
            float4 _light_color;
            float _smoothness;
            float _metallic;
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
                
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightVector = -lightDirection;
                float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldPos);
                
                float3 specularTint;
                float oneMinusReflectivity;
                float3 albedo = DiffuseAndSpecularFromMetallic(_albedo.rgb, _metallic, specularTint, oneMinusReflectivity);

                UnityLight light;
                light.color = _directionalLightColor;
                light.dir = lightVector;
                light.ndotl = saturate(dot(worldNormal, lightVector));

                float3 reflectDir = reflect(-viewVector, worldNormal);
                float perceptualRoughness = 1.0 - _smoothness;
                float mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
                float4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectDir, mip);
                float3 indirectSpecular = DecodeHDR(rgbm, unity_SpecCube0_HDR);
                
                UnityIndirect indirectLight;
                indirectLight.diffuse = _ambientLightColor;
                indirectLight.specular = indirectSpecular;


                float4 surfaceLight = UNITY_BRDF_PBS(
					albedo,
                    specularTint,
					oneMinusReflectivity,
                    _smoothness,
					worldNormal,
                    viewVector,
					light,
                    indirectLight
				);

                surfaceLight.a = 1.0;
                return surfaceLight;
            }
            ENDCG
        }
    }
}