Shader "ShaderCastle/Tutorials/VertexShader/Wireframe"
{
    Properties
    {
        _lineThickness ("Line thickness", float) = 0.05
        _baseColor ("Base color", color) = (0,0,0,1)
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
            #pragma geometry geom

            #include "Lighting.cginc"
            
            // Based on https://www.youtube.com/watch?v=ehk8ljz2nHI
            
            float _lineThickness;
            half4 _baseColor;
            half4 _lineColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2g {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };
            
            v2g vert (appdata v) {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }
            
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };
            
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
                g2f o;

                o.pos = IN[0].pos;
                o.worldNormal = IN[0].worldNormal;
                o.barycentric = float3(1.0, 0.0, 0.0);
                triStream.Append(o);
                
                o.pos = IN[1].pos;
                o.worldNormal = IN[1].worldNormal;
                o.barycentric = float3(0.0, 1.0, 0.0);
                triStream.Append(o);

                o.pos = IN[2].pos;
                o.worldNormal = IN[2].worldNormal;
                o.barycentric = float3(0.0, 0.0, 1.0);
                triStream.Append(o);
            }

            half4 frag (g2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float closest = min(i.barycentric.x, min(i.barycentric.y, i.barycentric.z));
                float frame = step(closest, _lineThickness);

                half3 albedo = lerp(_baseColor, _lineColor, frame);

                // Light
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                half3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                half3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                half3 directLight = NdotL * lightColor.rgb;

                half3 color = half3((directLight + ambientLight) * albedo);

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
