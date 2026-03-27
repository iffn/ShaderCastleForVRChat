Shader "ShaderCastle/Basics/ScreenCoordinate"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                // i.pos.xy returns the current pixel coordinate of the fragment
                // _ScreenParams.xy is the screen resolution in pixels
                float2 screenUV = i.pos.xy / _ScreenParams.xy;
                fixed4 col = fixed4(screenUV, 0.0, 1.0);
                return col; // Red
            }
            ENDCG
        }
    }
}
