Shader "ShaderCastle/Implementations/Environment/TriplanarTerrain"
{
    Properties
    {
        [NoScaleOffset]_TopTexture ("Top texture", 2D) = "white" {}
        [NoScaleOffset]_CliffTexture ("Cliff texture", 2D) = "white" {}
        _Transition ("Transition", Float) = 0.717
        _Sharpness ("Sharpness", Range(1, 64)) = 2.0
        _MainTexScale ("Texture Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }  

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _TopTexture;
            sampler2D _CliffTexture;
            float _Transition;
            float _Sharpness;
            float _MainTexScale;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.normal = v.normal;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            half3 triplanarColor(sampler2D lookupTexture, float3 pos, float3 normal) {
                float3 weights = abs(normal);
                weights = pow(weights, _Sharpness);
                weights /= (weights.x + weights.y + weights.z);

                float3 direction = sign(normal);

                float2 uvX = float2(pos.z * direction.x, pos.y) * _MainTexScale;
                float2 uvY = float2(pos.x * direction.y, pos.z) * _MainTexScale;
                float2 uvZ = float2(pos.x * -direction.z, pos.y) * _MainTexScale;

                half4 colX = tex2D(lookupTexture, uvX);
                half4 colY = tex2D(lookupTexture, uvY);
                half4 colZ = tex2D(lookupTexture, uvZ);

                half4 finalCol = colX * weights.x + colY * weights.y + colZ * weights.z;
                return finalCol;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                half3 cliff = triplanarColor(_CliffTexture, i.localPos, i.normal);
                half3 top = tex2D(_TopTexture, i.localPos.xz);
                float mask = smoothstep(_Transition - 0.05, _Transition + 0.05, i.normal.y);
                float3 albedo = lerp(cliff, top, mask);

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
    Fallback "VertexLit" // Light weight shadow casting and depth writing
}