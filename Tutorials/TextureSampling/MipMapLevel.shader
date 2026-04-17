Shader "ShaderCastle/Basics/MipMapLevel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _mipMap ("MipMap", float) = 1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float _mipMap;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                // Adjust X for the 1.5 aspect ratio quad
                float2 uv = i.uv;
                
                float4 textureLookup = float4(uv, 0.0, _mipMap);
                
                fixed3 color = tex2Dlod(_MainTex, textureLookup);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
