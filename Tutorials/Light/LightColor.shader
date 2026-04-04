Shader "ShaderCastle/Light/LightColor"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" // Required for UnityObjectToWorldNormal   

            float3 _world_light_direction;
            half4 _light_color;

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
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                
                fixed3 NdotL = dot(worldNormal, normalized_world_light_direction);
                NdotL = saturate(NdotL);

                fixed3 diffuse = NdotL * _light_color.rgb;
                
                fixed4 color = fixed4(diffuse, 1);
                return color;
            }
            ENDCG
        }
    }
}