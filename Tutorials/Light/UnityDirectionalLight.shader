Shader "ShaderCastle/Light/UnityDirectionalLight"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" // Required for UnityObjectToWorldNormal
            #include "Lighting.cginc" // Required for _LightColor0

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                fixed3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                
                fixed3 diffuse = NdotL * lightColor;
                
                fixed4 color = fixed4(diffuse, 1);
                return color;
            }
            ENDCG
        }
    }
}