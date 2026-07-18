Shader "Unlit/Tree"
{
    Properties
    {
        _offset ("Offset", float) = 1.0
        _glossiness ("Glossiness", float) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        LOD 100
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest" }
        Cull off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float _offset;
            float _glossiness;
            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 pos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };


            v2f vert (appdata v)
            {
                float3 normalOS = v.normal;
                float3 tangentOS = v.tangent.xyz;
                float3 bitangentOS = cross(normalOS, tangentOS) * v.tangent.w;
                float3x3 tangentToOS = float3x3(tangentOS, bitangentOS, normalOS);

                float2 uvCenter = v.uv + float2(-0.5, -0.5);
                float2 scaledUV = _offset * uvCenter;

                float3 offset = (tangentOS * scaledUV.x) + (bitangentOS * scaledUV.y);
                float4 newVertexPosition = float4(v.vertex.xyz + offset, 1.0);

                v2f o;
                o.vertex = UnityObjectToClipPos(newVertexPosition);
                o.pos = newVertexPosition;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, newVertexPosition);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                o.uv = v.uv;

                return o;
            }
            
            #if defined(UNITY_COMPILER_HLSL) || defined(SHADER_API_D3D11)
            [earlydepthstencil]
            #endif
            float4 frag (v2f i) : SV_Target
            {
                float4 textureColor = tex2D(_MainTex, i.uv);
                float3 albedo = textureColor.rgb;
                clip(textureColor.a - 0.9);
                
                // Light:
                float3 worldNormal = i.worldNormal;
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                float3 directLight = NdotL * lightColor.rgb;

                float3 color = (directLight + ambientLight) * albedo;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
