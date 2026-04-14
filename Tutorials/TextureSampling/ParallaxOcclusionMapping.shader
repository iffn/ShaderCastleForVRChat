Shader "ShaderCastle/TextureSampling/ParallaxOcclusionMapping"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        [NoScaleOffset]_HeightMap ("Heightmap", 2D) = "black" {}
        _HeightScale ("Height Scale", Range(0, 1)) = 0.05
        _MaxSamples ("Max Samples", Range(1, 64)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _HeightMap;
            float _HeightScale;
            float _MaxSamples;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDirTS : TEXCOORD1;  // view direction tangent space
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 objViewDir = ObjSpaceViewDir(v.vertex);

                float3 normal = v.normal;
                float3 tangent = v.tangent.xyz;
                float3 binormal = cross(normal, tangent) * v.tangent.w;

                float3x3 objToTangent = float3x3(tangent, binormal, normal);
                o.viewDirTS = mul(objToTangent, objViewDir);

                return o;
            }

            float sampleHeightmap(float2 uv) {
                return tex2D(_HeightMap, uv).r;
            }

            // Parallax Occlusion Mapping Logic
            float2 ParallaxOcclusionMapping(float2 uv, float3 viewDirTS) {
                float minSamples = _MaxSamples * 0.5;
                float numSamples = lerp(_MaxSamples, minSamples, abs(dot(float3(0, 0, 1), viewDirTS)));
                float stepHeight = 1.0 / numSamples;
                
                float2 parallaxLimit = -viewDirTS.xy / viewDirTS.z * _HeightScale;
                float2 uvOffsetStep = parallaxLimit / numSamples;

                float currentLayerHeight = 1.0;
                float2 currentUV = uv;
                float heightMapValue = sampleHeightmap(currentUV);

                // Raymarch
                [loop]
                for (int i = 0; i < numSamples; i++) {
                    if (heightMapValue < currentLayerHeight) {
                        currentLayerHeight -= stepHeight;
                        currentUV += uvOffsetStep;
                        heightMapValue = sampleHeightmap(currentUV);
                    } else {
                        break;
                    }
                }

                // Refinement: Linear Interpolation between the last two steps
                float2 prevUV = currentUV - uvOffsetStep;
                float nextH = heightMapValue - currentLayerHeight;
                float prevH = sampleHeightmap(prevUV) - (currentLayerHeight + stepHeight);
                float weight = nextH / (nextH - prevH);
                
                return prevUV * weight + currentUV * (1.0 - weight);
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 offsetUV = ParallaxOcclusionMapping(i.uv, normalize(i.viewDirTS));
                
                fixed3 color = tex2D(_MainTex, offsetUV);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}