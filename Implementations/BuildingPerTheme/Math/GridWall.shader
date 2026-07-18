Shader "ShaderCastle/Implementations/BuildingPerTheme/Math/GridWall"
{
    Properties
    {
        _zoom ("Zoom", float) = 1
        _lineThickness ("Line thickness", float) = 0.05
        _wallColor ("Wall color", color) = (0,0,0,1)
        _lineColor ("Line color", color) = (1,1,1,1)
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
            float4 _wallColor;
            float4 _lineColor;

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
            
            float stepPattern(float x){
                float y = frac(x * 0.5);
                y -= 0.5;
                y = sign(y);
                y = saturate(y);
                return y;
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float3 pos3D = i.vertex.xyz;

                pos3D *= _zoom;

                float3 sawtooth3 = abs(frac(pos3D) - 0.5) * 2.0;
                float3 linePattern3 = step(1.0 - _lineThickness, sawtooth3);
                
                float linePattern = saturate(linePattern3.x + linePattern3.y + linePattern3.z);

                float3 albedo = lerp(_wallColor, _lineColor, linePattern);

                // Light
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                float3 directLight = NdotL * lightColor.rgb;

                float3 color = float3((directLight + ambientLight) * albedo);

                return float4 (color, 1.0);
            }
            ENDCG
        }
    }
}
