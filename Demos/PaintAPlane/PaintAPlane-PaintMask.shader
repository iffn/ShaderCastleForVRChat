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
            Conservative True
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _albedo;
            float _modelScale;
            float3 _brushPositionLocal;
            float _brushSize;
            float3 _brushColor;

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

            float4 frag (v2f i) : SV_Target {
                float distance = length(i.localPos - _brushPositionLocal);

                float brushMask = saturate(sign(_brushSize - distance));

                float3 baseColor = float3(0,0,0);
                float3 brushMaskColor = float3(1,1,1);

                float3 color = lerp(baseColor, brushMaskColor, brushMask);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
