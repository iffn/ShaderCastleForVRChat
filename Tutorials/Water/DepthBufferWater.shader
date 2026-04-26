Shader "ShaderCastle/Tutorials/Water/DepthBufferWater"
{
    Properties
    {
        _Albedo ("Water Color", Color) = (0.2, 0.2, 1.0, 1.0)
        _Density ("Water Density", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            UNITY_DECLARE_SCREENSPACE_TEXTURE(_CameraDepthTexture);
            fixed4 _Albedo;
            float _Density;

            struct appdata {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
                float eyeDepth : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.eyeDepth = -UnityObjectToViewPos(v.vertex).z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                fixed4 col = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
                
                float depth = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraDepthTexture, screenUV).r;
                float sceneEyeDepth = LinearEyeDepth(depth);

                float waterDepth = sceneEyeDepth - i.eyeDepth;

                // Apply Beer's Law
                float transmission = exp(-_Density * waterDepth);
                float extinction = 1.0 - transmission;

                fixed4 finalCol = _Albedo;
                finalCol.a = saturate(extinction + _Albedo.a);

                return finalCol;
            }
            ENDCG
        }
    }
}