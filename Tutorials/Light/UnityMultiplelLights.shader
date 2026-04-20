Shader "ShaderCastle/Tutorials/Light/UnityMultiplelLights"
{
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                half3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                
                half3 diffuse = NdotL * lightColor;
                
                half3 color = half3(diffuse);
                return half4(color, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd // Tells Unity to run this pass for all extra lights

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir;
                float attenuation;

                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    attenuation = 1.0;
                } else {
                    float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - i.worldPos;
                    float distance = length(vertexToLightSource);
                    lightDir = normalize(vertexToLightSource);
                    
                    attenuation = 1.0 / (1.0 + distance * distance);
                }

                half3 diffuse = saturate(dot(lightDir, worldNormal)) * _LightColor0.rgb * attenuation;
                return half4(diffuse, 1.0);
            }
            ENDCG
        }
    }
}