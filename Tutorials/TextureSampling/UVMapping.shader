Shader "ShaderCastle/Tutorials/TextureSampling/TextureDisplayWithTiling"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        _modelScale ("Model scale", float) = 1.0
    }
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _albedo;
            float _modelScale;

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
                float4 pos = v.vertex;
                float2 uv = v.uv - float2(0.5, 0.5);
                float4 uvPos = float4(uv.x, 0.0, uv.y, 0.0);
                
                float lerpValue = sin(_Time.y) * 0.5 + 0.5;
                
                float4 finalPos = lerp(pos * _modelScale, uvPos, lerpValue);

                o.pos = UnityObjectToClipPos(finalPos);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_albedo, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
