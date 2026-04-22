Shader "ShaderCastle/Tutorials/DepthBuffer/DepthBufferWriteGreaterEqual"
{
    Properties
    {
        _depthWrite ("Depth write", float) = 1.0
        
    }
    SubShader
    {
        Pass
        {
            ZTest LEqual
            ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
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
                half4 color : SV_Target;
                float depth : SV_DepthGreaterEqual;
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
                half3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                half3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                half3 directLight = NdotL * lightColor.rgb;
                half3 albedo = half3(1.0, 0.2, 0.2);
                half3 color = (directLight + ambientLight) * albedo;

                frag_out o;
                o.color = half4(color, 1.0);
                o.depth = _depthWrite;

                return o;
            }
            ENDCG
        }
    }
}