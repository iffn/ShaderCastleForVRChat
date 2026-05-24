Shader "ShaderCastle/Demos/PaintAPlane/PaintAPlane-PaintMask"
{
    Properties
    {
        _modelScale ("Model scale", float) = 1.0
        _brushPositionLocal ("Brush position local", vector) = (0, 0, 0)
        _brushSize ("Brush size", float) = 0.1
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
            float3 _brushPositionLocal;
            float _brushSize;
            fixed3 _brushColor;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                float4 pos = v.vertex;
                float2 uv = v.uv - float2(0.5, 0.5);
                float4 uvPos = float4(uv.x, 0.0, uv.y, 0.0);

                o.pos = UnityObjectToClipPos(uvPos);
                o.localPos = v.vertex;
                o.uv = v.uv;
                return o;
            }
            /*
            half4 frag (v2f i) : SV_Target {
                float brushMask = saturate(sign(_brushSize - (i.localPos - _brushPositionLocal)));
                brushMask = length(i.localPos - _brushPositionLocal);

                half3 renderTextureColor = tex2D(_albedo, i.uv);

                half3 color = lerp(_brushColor, renderTextureColor, brushMask);
                return half4(color, 1.0);
            }
            */

            half4 frag (v2f i) : SV_Target {
                float distance = length(i.localPos - _brushPositionLocal);

                float brushMask = saturate(sign(_brushSize - distance));

                half3 baseColor = half3(0,0,0);
                half3 brushMaskColor = half3(1,1,1);

                half3 color = lerp(baseColor, brushMaskColor, brushMask);
                
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
