Shader "ShaderCastle/Tutorials/TextureSampling/MipMapSize"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;
                uv.x *= 1.5;

                float isSidebar = step(1.0, uv.x);

                float mipLevel = floor(log2(1.0 / (1.0001 - uv.y))) + 2; 
                mipLevel = lerp(1.0, mipLevel, isSidebar);
                
                float2 sidebarUV;
                sidebarUV.x = (uv.x - 1.0) * pow(2.0, mipLevel - 1);
                sidebarUV.y = frac(uv.y * pow(2.0, mipLevel - 1));

                float2 lookupUV = lerp(uv, sidebarUV, isSidebar);

                float outOfBounds = step(1.0, sidebarUV.x) * isSidebar;
                clip(0.5 - outOfBounds);
                
                float4 textureLookup = float4(lookupUV, 0.0, mipLevel);
                
                fixed3 color = tex2Dlod(_MainTex, textureLookup);
                // color = fixed3(mipLevel * 0.1, 0.0, 0.0); // MipMap debug
                // color = fixed3(lookupUV, 0.0); // Lookup debug

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
