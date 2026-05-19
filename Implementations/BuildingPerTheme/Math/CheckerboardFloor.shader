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
            half4 _lineColor;
            half4 _colorA;
            half4 _colorB;

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

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float2 pos2D = i.vertex.xy;

                pos2D *= _zoom;

                float2 checkerboardPattern2 = saturate(sign(frac(pos2D * 0.5) - 0.5));
                float checkerboardPattern = abs(checkerboardPattern2.x - checkerboardPattern2.y);

                float2 sawtooth2 = abs(frac(pos2D) - 0.5) * 2.0;
                float2 linePattern2 = step(1.0 - _lineThickness, sawtooth2);
                float linePattern = saturate(linePattern2.x + linePattern2.y);

                half3 albedo = lerp(_colorA, _colorB, checkerboardPattern);
                albedo = lerp(albedo, _lineColor, linePattern);

                // Light
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                half3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                half3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                half3 directLight = NdotL * lightColor.rgb;

                half3 color = half3((directLight + ambientLight) * albedo);

                return half4 (color, 1.0);
            }
            ENDCG
        }
    }
}
