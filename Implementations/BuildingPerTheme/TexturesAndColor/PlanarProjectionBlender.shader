Shader "ShaderCastle/Implementations/BuildingPerTheme/TexturesAndColor/PlanarProjectionBlender"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _MainTexScale ("Texture Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
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
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            float2 TextureProijectionUVs(float3 position, float3 projectionVector)
            {
                float3 N = normalize(projectionVector);
                
                float3 reference = (abs(N.z) > 0.99) ? float3(0, 1, 0) : float3(0, 0, 1);
                
                float3 U_axis = normalize(cross(reference, N));
                float3 V_axis = cross(N, U_axis);
                
                float u = dot(position, U_axis);
                float v = dot(position, V_axis);
                
                return float2(u, v);
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);

                float2 projectedUV = TextureProijectionUVs(i.localPos, i.normal);
                
                half3 albedo = tex2D(_MainTex, projectedUV);

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