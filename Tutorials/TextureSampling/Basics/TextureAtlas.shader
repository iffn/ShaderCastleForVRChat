Shader "ShaderCastle/Tutorials/TextureSampling/TextureAtlasPixels"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CellSize ("Cell Size in Pixels (Width, Height)", Vector) = (8, 16, 0, 0)
        _LookupX ("Lookup coordinate X", float) = 0
        _LookupY ("Lookup coordinate Y", float) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize; // z = width, w = height
            float4 _CellSize;
            float _LookupX;
            float _LookupY;

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

            half4 frag (v2f i) : SV_Target {
                float2 lookupCoordinate = float2(_LookupX, _LookupY);

                // _TexelSize: x = 1/xCount, y = 1/yCount, z = xCount, w = yCount
                float2 texelSize = _MainTex_TexelSize.xy;

                float2 localPixel = floor(frac(i.uv) * _CellSize.xy);

                float2 pixelOffset = lookupCoordinate * _CellSize.xy;

                float2 finalPixel = pixelOffset + localPixel + 0.5;

                float2 finalUV = finalPixel * texelSize;

                half3 color = tex2D(_MainTex, finalUV).rgb;
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}