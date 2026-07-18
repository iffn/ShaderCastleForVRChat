Shader "ShaderCastle/Tutorials/Stencil/StencilBasicRead"
{
    Properties
	{
		_mask ("Write mask", Integer) = 1
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" } // Mask needs to write before this

        Pass
        {
            Stencil {
                Ref [_mask] // What the values need to be to render,  with 1: xxxx xxx1 (x doesn't matter because of the mask)
                ReadMask 255 // Only the last bit should be read, with 1: 0000 0001
                Comp Equal
                Pass Keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;
                float3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);
                float3 directLight = NdotL * lightColor.rgb;
                float3 white = float3(1.0, 1.0, 1.0);

                float3 color = float3((directLight + ambientLight) * white);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}