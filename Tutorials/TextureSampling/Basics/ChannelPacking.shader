Shader "ShaderCastle/Tutorials/TextureSampling/ChannelPacking"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _red ("Red", Range(0.0, 1.0)) = 1.0
        _green ("Green", Range(0.0, 1.0)) = 0.0
        _blue ("Blue", Range(0.0, 1.0)) = 0.0
        _alpha ("Alpha", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float _red;
            float _green;
            float _blue;
            float _alpha;

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
                float4 color = tex2D(_MainTex, i.uv);

                float r = color.r * _red;
                float g = color.g * _green;
                float b = color.b * _blue;
                float a = color.a * _alpha;
                float sum = r + g + b + a;
                sum = saturate(sum);

                return float4(sum.rrr, 1.0);
            }
            ENDCG
        }
    }
}
