Shader "ShaderCastle/Tutorials/DepthBuffer/FootstepDisplay"
{
    Properties
    {
        footstepCRT("Footstep CRT", 2D) = "white" {}
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

            sampler2D footstepCRT;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                o.uv = v.uv;
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
                
                half3 albedo = tex2D(footstepCRT, i.uv).rgb;
                half3 color = (directLight + ambientLight) * albedo;
                
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}