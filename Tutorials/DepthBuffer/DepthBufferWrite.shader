Shader "ShaderCastle/Tutorials/DepthBuffer/DepthBufferWrite"
{
    Properties
    {
        _depthWrite ("Depth write", float) = 1.0
        
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

            float _depthWrite;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            struct frag_out {
                float4 color : SV_Target;
                float depth : SV_Depth;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            frag_out frag (v2f i) {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                float3 directLight = NdotL * lightColor.rgb;
                float3 albedo = float3(1.0, 0.2, 0.2);
                float3 color = (directLight + ambientLight) * albedo;

                frag_out o;
                o.color = float4(color, 1.0);
                o.depth = _depthWrite;

                return o;
            }
            ENDCG
        }
    }
}