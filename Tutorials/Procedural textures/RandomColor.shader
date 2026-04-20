Shader "ShaderCastle/Tutorials/ProceduralTextures/RandomColor"
{
    Properties
    {
        _zoom ("Zoom", float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            float _zoom;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
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
            
            half4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;
                pos2D *= _zoom;

                float2 gridID = floor(pos2D);

                float randomSeed01 = hash11(hash11(gridID.x) + gridID.y);

                float r = randomSeed01;
                float g = hash11(r);
                float b = hash11(g);

                half3 color = half3(r, g, b);
                return half4(color, 1.0);
            }

            ENDCG
        }
    }
}
