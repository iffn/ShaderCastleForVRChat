Shader "ShaderCastle/Tutorials/TextureSampling/MipMapLevel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _mipMap ("MipMap", float) = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float _mipMap;

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
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;
                
                float4 textureLookup = float4(uv, 0.0, _mipMap);
                
                fixed3 color = tex2Dlod(_MainTex, textureLookup);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
