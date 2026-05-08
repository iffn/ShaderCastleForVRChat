Shader "ShaderCastle/Tutorials/Light/Albedo"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _albedo ("Albedo", color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _world_light_direction;
            half4 _albedo;
            half4 _light_color;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); // Part of UnityCG.cginc
                o.worldNormal = normalize(o.worldNormal); // Make sure the world normals are normalized

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);

                half3 diffuse = dot(normalized_world_light_direction, worldNormal);
                diffuse *= _albedo;
                diffuse *= _light_color.rgb;
                diffuse = saturate(diffuse);
                
                return half4(diffuse, 1.0);
            }
            ENDCG
        }
    }
}