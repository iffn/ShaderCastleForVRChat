Shader "ShaderCastle/Tutorials/TextureSampling/ParallaxOcclusionMappingWithDepthWrite"
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
            #pragma target 5.0
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
                float3 viewDirTS : TEXCOORD1;
                float4 posView : TEXCOORD3;
            };
            
            struct frag_out {
                fixed4 color : SV_Target;
                float depth : SV_DepthGreaterEqual;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.posView = mul(UNITY_MATRIX_MV, v.vertex); 

                float3 objViewDir = ObjSpaceViewDir(v.vertex);
                float3x3 objToTangent = float3x3(v.tangent.xyz, cross(v.normal, v.tangent.xyz) * v.tangent.w, v.normal);
                o.viewDirTS = mul(objToTangent, objViewDir);

                return o;
            }

            float sampleHeightmap(float2 uv) {
                return tex2D(_HeightMap, uv).r;
            }

            float2 ParallaxOcclusionMapping(float2 uv, float3 viewDirTS, out float outHeight) {
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
                
                float2 finalUV = prevUV * weight + currentUV * (1.0 - weight);
                
                outHeight = heightMapValue; 
                
                return finalUV;
            }

            frag_out frag (v2f i) {
                float3 viewDirTS = normalize(i.viewDirTS);
                float finalHeight;
                
                float2 offsetUV = ParallaxOcclusionMapping(i.uv, viewDirTS, finalHeight);
                
                frag_out o;

                o.color = tex2D(_MainTex, offsetUV);

                float depthOffset = (1.0 - finalHeight) * _HeightScale;
                float viewSpaceZOffset = depthOffset / viewDirTS.z;
                float newViewZ = i.posView.z - viewSpaceZOffset;
                float4 clipPos = mul(UNITY_MATRIX_P, float4(i.posView.xy, newViewZ, i.posView.w));
                o.depth = clipPos.z / clipPos.w;

                return o;
            }
            ENDCG
        }
    }
}