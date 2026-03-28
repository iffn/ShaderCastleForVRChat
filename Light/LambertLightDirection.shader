Shader "ShaderCastle/Light/LambertLightDirection"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
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
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized

                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float3 normalized_world_light_direction = normalize(_world_light_direction);
                fixed4 diffuse = dot(normalized_world_light_direction, i.worldNormal);
                return diffuse;
            }
            ENDCG
        }
    }
}