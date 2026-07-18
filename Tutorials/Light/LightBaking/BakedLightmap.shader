Shader "ShaderCastle/Tutorials/Light/BakedLightmap"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON // Compiles variants for when lightmapping
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // Required for _LightColor0

            float4 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord1 : TEXCOORD1; // Pull the lightmap UVs from the mesh's second UV channel
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                #ifdef LIGHTMAP_ON
                float2 lightmapUV : TEXCOORD1; // Define a variable to pass the lightmap UV to the fragment shader
                #endif
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                #ifdef LIGHTMAP_ON
                o.lightmapUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw; // Scale and offset the lightmap UVs using Unity's built-in ST variables
                #endif

                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 emissiveLight = float3(0.0, 0.0, 0.0);

                // Light hitting the surface:
                float3 surfaceIrradiance = float3(0.0, 0.0, 0.0);

                #ifdef LIGHTMAP_ON
                    float4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV); // Sample the global lightmap texture
                    surfaceIrradiance = DecodeLightmap(bakedColorTex); // Decode handles differences between color spaces (Gamma/Linear) and HDR
                #else
                    surfaceIrradiance = UNITY_LIGHTMODEL_AMBIENT.rgb; // Fallback to flat ambient light if the object isn't lightmapped
                #endif
                
                float3 BRDFLightFactor = _albedo.rgb;
                float3 reflectedLight = BRDFLightFactor * surfaceIrradiance;

                float3 surfaceLight = emissiveLight + reflectedLight;

                return float4(surfaceLight, 1.0);
            }
            ENDCG
        }
    }
}