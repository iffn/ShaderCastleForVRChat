Shader "ShaderCastle/Light/DepthBufferWrite"
{
    Properties
    {
        _depthWrite ("depthWrite", float) = 1
        
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

            float _depthWrite;

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

            struct frag_out {
                fixed4 color : SV_Target;
                float depth : SV_Depth; // This allows you to "set" the depth
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized

                return o;
            }

            // Fragment function
            frag_out frag (v2f i) {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                fixed3 directLight = NdotL * lightColor.rgb;
                
                fixed3 albedo = fixed3(1.0, 0.2, 0.2);

                frag_out o;
                o.color = fixed4((directLight + ambientLight) * albedo, 1);
                o.depth = _depthWrite;

                return o;
            }
            ENDCG
        }
    }
}