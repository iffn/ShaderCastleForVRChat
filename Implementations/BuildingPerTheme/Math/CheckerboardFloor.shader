Shader "ShaderCastle/Implementations/BuildingPerTheme/Math/CheckerboardFloor"
{
    Properties
    {
        _zoom ("Zoom", float) = 1
        _lineThickness ("Line thickness", float) = 0.05
        _colorA ("Color A", color) = (1,1,1,1)
        _colorB ("Color B", color) = (0,0,0,1)
        _lineColor ("Line color", color) = (0,0,0,1)
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
            #include "Lighting.cginc"

            float _zoom;
            float _lineThickness;
            float4 _lineColor;
            float4 _colorA;
            float4 _colorB;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float2 pos2D = i.vertex.xy;

                pos2D *= _zoom;

                float2 checkerboardPattern2 = saturate(sign(frac(pos2D * 0.5) - 0.5));
                float checkerboardPattern = abs(checkerboardPattern2.x - checkerboardPattern2.y);

                float2 sawtooth2 = abs(frac(pos2D) - 0.5) * 2.0;
                float2 linePattern2 = step(1.0 - _lineThickness, sawtooth2);
                float linePattern = saturate(linePattern2.x + linePattern2.y);

                float3 albedo = lerp(_colorA, _colorB, checkerboardPattern);
                albedo = lerp(albedo, _lineColor, linePattern);

                return float4 (albedo, 1.0);
            }
            ENDCG
        }
    }
}
