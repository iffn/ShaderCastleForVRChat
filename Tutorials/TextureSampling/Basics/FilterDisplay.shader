Shader "ShaderCastle/Tutorials/TextureSampling/FilterDisplay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _pinch ("Texture", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float _pinch;

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

            // Fragment function
            float4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;

                // Calculate how much to pinch based on the vertical coordinate and the parameter
                // This ensures the pinching is strongest at the top (uv.y = 1) and zero at the bottom (uv.y = 0)
                float denominator = max(1.0 - (_pinch * uv.y), 0.0001);

                // Scale the X coordinate away from the center (0.5)
                uv.x = 0.5 + (uv.x - 0.5) / denominator;

                float3 color = tex2D(_MainTex, uv);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
