Shader "ShaderCastle/Implementations/BuildingPerTheme/Math/Voronoi3DWall"
{
    Properties
    {
        _patternAngle ("Pattern angle", float) = 2
        _base ("Base", color) = (0.1, 0.1, 0.1, 1.0)
        _shape ("Shape", color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma target 3.5

            float _patternAngle;
            float4 _base;
            float4 _shape;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_LIGHTING_COORDS(2, 3) // Hidden data channels for light/shadow maps
                float3 localPos : TEXCOORD4;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_VERTEX_TO_FRAGMENT(o); // Populates the internal light coordinates
                return o;
            }

            float hash11(float p) {
                uint h = asuint(p);

                h ^= 0x27D4EB2DU; 

                h = h * 1103515245U + 12345U;
                h ^= (h >> 16);
                h *= 0x85ebca6bU;
                h ^= (h >> 13);
                h *= 0xc2b2ae35U;
                h ^= (h >> 16);

                return float(h & 0x00ffffffu) / float(0x01000000u);
            }

            float4 frag (v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                
                float3 lightVector;
                // _WorldSpaceLightPos0.w is 0 for Directional, 1 for Point/Spot
                if (_WorldSpaceLightPos0.w == 0.0) {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz);
                } else {
                    lightVector = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                }
                
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos); // Unity macro that writes to the attenuation variable defined in AutoLight.cginc
                float3 radiantIntensity = _LightColor0.rgb * attenuation; // Correct Unity formula, _LightColor0.rgb also holds intensity.
                
                float NdotL01 = saturate(dot(worldNormal, lightVector));
                float3 surfaceIrradiance = radiantIntensity * NdotL01;

                surfaceIrradiance += UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                float3 localPos = i.localPos;

                float angleRad = atan2(localPos.y, localPos.x);
                float angleDeg = angleRad * 57.29578 + 180;
                angleDeg = angleDeg % _patternAngle;

                float lerpValue = step(_patternAngle * 0.1, angleDeg);

                float3 albedo = lerp(_base, _shape, lerpValue);

                float3 BRDFLightFactor = albedo;
                float3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                return float4(surfaceRadiance, 1.0);
            }

            ENDCG
        }
    }
}
