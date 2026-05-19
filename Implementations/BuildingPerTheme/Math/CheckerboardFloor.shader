Shader "ShaderCastle/Implementations/BuildingPerTheme/Math/CheckerboardFloor"
{
    Properties
    {
        _colorA ("Color A", color) = (1,1,1,1)
        _colorB ("Color B", color) = (0,0,0,1)
        _zoom ("Zoom", float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float _zoom;
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
            
            float stepPattern(float x){
                float y = frac(x * 0.5);
                y -= 0.5;
                y = sign(y);
                y = saturate(y);
                return y;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float2 pos2D = i.vertex.xy;

                pos2D *= _zoom;

                half3 black = (0.0, 0.0, 0.0);
                half3 white = (1.0, 1.0, 1.0);

                
                float xStep = stepPattern(pos2D.x);
                float yStep = stepPattern(-pos2D.y);
                float pattern = abs(xStep - yStep);

                half3 albedo = lerp(_colorA, _colorB, pattern);

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
