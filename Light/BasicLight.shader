Shader "ShaderCastle/Light/BasicLight"
{
    SubShader
    {
        // Adding a LightMode tag tells Unity to send light data to this pass
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" // Required for _LightColor0

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL; // 1. Pull normals from the mesh
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0; // 2. Pass normal to fragment
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // Convert the normal from local object space to world space
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // 3. Normalize the directions
                float3 normal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 4. The Dot Product (Lambertian Shading)
                // This returns 1.0 if facing the light, 0.0 if perpendicular
                float dotProduct = max(0.0, dot(normal, lightDir));
                
                // 5. Multiply light color by the dot product
                fixed3 diffuse = dotProduct * _LightColor0.rgb;

                return fixed4(diffuse, 1.0);
            }
            ENDCG
        }
    }
}