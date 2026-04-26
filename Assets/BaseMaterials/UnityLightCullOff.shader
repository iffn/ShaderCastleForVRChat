Shader "ShaderCastle/Environment/UnityLightCullOff"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Cull off
            ZWrite on
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            half4 _albedo;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target {
                float3 worldNormal = i.worldNormal * (facing > 0 ? 1.0 : -1.0);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                fixed3 directLight = NdotL * lightColor.rgb;
                
                fixed4 color = fixed4((directLight + ambientLight) * _albedo, 1);
                return color;
            }
            ENDCG
        }
    }
    Fallback "VertexLit"
}