Shader "ShaderCastle/Basics/DepthBufferReadScreen"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                
                float aspectRatio = _ScreenParams.x / _ScreenParams.y;
                v.vertex.x *= aspectRatio;

                o.pos = UnityObjectToClipPos(v.vertex); // Basic object to clip space transformation
                o.uv = v.uv;
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                return fixed4(col);
            }
            ENDCG
        }
    }
}
