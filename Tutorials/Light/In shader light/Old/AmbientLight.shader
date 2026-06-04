Shader "ShaderCastle/Tutorials/Light/AmbientLight"
{
    Properties
    {
        _world_light_direction ("World light direciton", Vector) = (1,1,1,0)
        _light_color ("Light color", color) = (1,1,1,1)
        _ambient_light_color ("Ambient light color", color) = (1,1,1,1)
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
            half4 _light_color;
            half4 _ambient_light_color;
            half4 _albedo;

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
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);

                return o;
            }

            half4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 normalized_world_light_direction = normalize(_world_light_direction);

                half3 NdotL = dot(worldNormal, normalized_world_light_direction);
                NdotL = saturate(NdotL);

                half3 diffuse = NdotL * _light_color.rgb;
                
                half3 color = half3((diffuse + _ambient_light_color) * _albedo);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}