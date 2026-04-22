Shader "ShaderCastle/Tutorials/Transparency/CutoutWithEarlydepthstencilClip"
{
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag



            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Compiler statements commented out for this demo to see when it fails
            //#if defined(UNITY_COMPILER_HLSL) || defined(SHADER_API_D3D11)
            [earlydepthstencil]
            //#endif
            half4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;

                float distanceToCenter = length(uv - float2(0.5, 0.5));

                clip(0.5 - distanceToCenter);
                
                half3 color = half3(1.0, 1.0, 1.0);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
