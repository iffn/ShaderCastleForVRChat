Shader "ShaderCastle/Tutorials/Basics/TextureDisplay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;

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
                float3 black = float3(0.0, 0.0, 0.0);
                float3 white = float3(1.0, 1.0, 1.0);
                float3 textureLookup = tex2D(_MainTex, i.uv);
                float3 color = lerp(black, white, textureLookup.x);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
