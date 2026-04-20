Shader "ShaderCastle/Tutorials/Light/AmbientLight"
{
    Properties
    {
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // Required for _LightColor0

            half4 _albedo;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                half3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                half3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                half3 directLight = NdotL * lightColor.rgb;
                
                half3 color = half3((directLight + ambientLight) * _albedo);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}