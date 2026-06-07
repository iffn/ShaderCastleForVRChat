Shader "Unlit/Tree"
{
    Properties
    {
        _zoom ("Scale", float) = 1.0
        _glossiness ("Glossiness", float) = 0.5
        _color1 ("Color 1", Color) = (1,1,1,1)
        _color2 ("Color 2", Color) = (1,1,1,1)
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

            float _zoom;
            float _glossiness;
            fixed3 _color1;
            fixed3 _color2;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 pos : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.vertex;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = normalize(o.worldNormal);
                return o;
            }

            float hash11(float p)
            {
                if(p == -0)
                    p = 0;

                uint h = asuint(p+0.0);

                h ^= 0x27D4EB2DU; 

                h = h * 1103515245U + 12345U;
                h ^= (h >> 16);
                h *= 0x85ebca6bU;
                h ^= (h >> 13);
                h *= 0xc2b2ae35U;
                h ^= (h >> 16);

                return float(h & 0x00ffffffu) / float(0x01000000u);
            }

            
            float hash21(float2 p, float seed = 0.0)
            {
                return hash11(hash11(hash11(p.x) + p.y) + seed);
            }

            float valueNoise2D(float2 uv, float seed = 0.0) {
                // Base parameters
				float2 i = floor(uv);
				float2 f = frac(uv);
                float2 u = f*f*(3.0-2.0*f); // Smoothstep between 0...1

                // Random weights
                float a = hash21(i + float2(0.0, 0.0), seed);
                float b = hash21(i + float2(1.0, 0.0), seed);
                float c = hash21(i + float2(0.0, 1.0), seed);
                float d = hash21(i + float2(1.0, 1.0), seed);

                // Bilinear interpolation
				float bottom = lerp(a, b, u.x);
				float top = lerp(c, d, u.x);
				return lerp(bottom, top, u.y);
			}

            float valueNoise3D(float3 pos, float seed = 0.0)
            {
                float3 i = floor(pos);
				float3 f = frac(pos);
                float3 u = f*f*(3.0-2.0*f); // Smoothstep between 0...1

                float bottom = valueNoise2D(pos.xz, i.y);
				float top = valueNoise2D(pos.xz, i.y + 1.0);
				return lerp(bottom, top, u.y);
            }

            half4 frag (v2f i) : SV_Target
            {
                // Based on https://www.shadertoy.com/view/lsf3WH
                float3x3 octaveTransform = float3x3(
                    0.00,  1.60,  1.20,
                    -1.60,  0.72, -0.96,
                    -1.20, -0.96,  1.28
                );
                
                // Noise
                float3 localPosModified = _zoom * i.pos;
                float noise = 0.5 * valueNoise3D(localPosModified);

                localPosModified = mul(octaveTransform, localPosModified);
                noise += 0.25 * valueNoise3D(localPosModified);

                half3 albedo = lerp(_color1, _color2, noise);

                
                // Light:
                float3 worldNormal = i.worldNormal;
                float3 _world_light_direction = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                fixed3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 NdotL = dot(worldNormal, _world_light_direction);
                NdotL = saturate(NdotL);

                fixed3 directLight = NdotL * lightColor.rgb;

                fixed3 color = (directLight + ambientLight) * albedo;

                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
