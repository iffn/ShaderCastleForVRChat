Shader "ShaderCastle/DepthBuffer/FootstepDisplay"
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
            #include "UnityCG.cginc" // Required for UnityObjectToWorldNormal 
            #include "Lighting.cginc" // Required for _LightColor0

            sampler2D footstepCRT;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized
                o.uv = v.uv;
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                fixed3 directLight = NdotL * lightColor.rgb;
                
                fixed3 albedo = tex2D(footstepCRT, i.uv).rgb;
                
                fixed4 color = fixed4((directLight + ambientLight) * albedo, 1);
                return color;
            }
            ENDCG
        }
    }
}