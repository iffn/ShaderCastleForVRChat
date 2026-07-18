Shader "ShaderCastle/Demos/PaintAPlane/PaintAPlane-Display"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);

                // sample the texture
                float3 albedo = tex2D(_MainTex, i.uv);
                saturate(albedo);

                // Light
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                float3 directLight = NdotL * lightColor.rgb;

                float3 color = float3((directLight + ambientLight) * albedo);

                return float4 (color, 1.0);
            }
            ENDCG
        }
    }
}
