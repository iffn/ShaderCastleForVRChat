Shader "ShaderCastle/Water/DepthBufferWater"
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

            sampler2D _CameraDepthTexture;
            fixed4 _Albedo;
            float _Density;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float eyeDepth : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                o.eyeDepth = -UnityObjectToViewPos(v.vertex).z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 screenUV = i.pos.xy / _ScreenParams.xy;
                fixed4 col = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
                
                float sceneRawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
                float sceneEyeDepth = LinearEyeDepth(sceneRawDepth);

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