Shader "ShaderCastle/Implementations/BuildingPerTheme/Math/Voronoi3DWall"
{
    Properties
    {
        _zoom ("Zoom", float) = 1
        _baseColor1 ("Base color 1", Color) = (1,1,1,1)
        _baseColor2 ("Base color 2", Color) = (1,1,1,1)
        _edgeColor ("Edge color", Color) = (1,1,1,1)
        _verticalStretch ("Vertical stretch", Range(0, 2)) = 1.0
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

            float _zoom;
            float3 _baseColor1;
            float3 _baseColor2;
            float3 _edgeColor;
            float _verticalStretch;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_LIGHTING_COORDS(2, 3) // Hidden data channels for light/shadow maps
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
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

            float3 voronoi3D(float3 position) {
                float3 baseCell = floor(position);

                float closestDistance = 8.0;
                float secondClosestDistance = 8.0;
                float closestSeed = 0;

                [unroll]
                for(int z = -1; z <= 1; z++) {
                    for(int y = -1; y <= 1; y++) {
                        [unroll]
                        for(int x = -1; x <= 1; x++) {
                            float3 cellOffset = float3(x, y, z);
                            float3 cell = baseCell + cellOffset;
                            float seed = hash11(hash11(cell.x) + cell.y) + cell.z;
                            
                            float3 randomOffset = float3(
                                hash11(seed + 111.111), 
                                hash11(seed + 222.222),
                                hash11(seed + 333.333)
                            );

                            float3 cellPosition = cell + randomOffset;
                            float3 distanceToCell = cellPosition - position;
                            float distance = length(distanceToCell);

                            if(distance < closestDistance) {
                                secondClosestDistance = closestDistance;
                                closestDistance = distance;
                                closestSeed = seed;
                            } else if (distance < secondClosestDistance) {
                                secondClosestDistance = distance;
                            }
                        }
                    }
                }

                float edgeDist = secondClosestDistance - closestDistance;
                
                float cellID = hash11(closestSeed);

                return float3(closestDistance, cellID, edgeDist);
            }
            
            float4 frag (v2f i) : SV_Target {
                float3 pos3D = i.worldPos.xyz;
                pos3D *= _zoom;
                pos3D.z *= _verticalStretch;

                float3 voronoiValues = voronoi3D(pos3D);

                float edgeLerp = step(0.05, voronoiValues.z);
                float3 baseColor = lerp(_baseColor1, _baseColor2, voronoiValues.y);
                float3 albedo = lerp(_edgeColor, baseColor, edgeLerp);

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
                
                float3 BRDFLightFactor = albedo;
                float3 surfaceRadiance = BRDFLightFactor * surfaceIrradiance;

                return float4(surfaceRadiance, 1.0);
            }

            ENDCG
        }
    }
}
