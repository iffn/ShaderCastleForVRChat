Shader "ShaderCastle/ProceduralTextures/Checkerboard"
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

            float _zoom;

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
            };

            // Transfer data from the vertex to the fragment function
            struct v2f {
                float4 pos : SV_POSITION;
                float4 vertex : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                // Basic object to clip space transformation
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            float stepPattern(float x){
                float y = frac(x * 0.5);
                y -= 0.5;
                y = sign(y);
                y = saturate(y);
                return y;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float2 pos2D = i.vertex.xy;

                pos2D *= _zoom;

                fixed3 black = (0.0, 0.0, 0.0);
                fixed3 white = (1.0, 1.0, 1.0);

                
                float xStep = stepPattern(pos2D.x);
                float yStep = stepPattern(-pos2D.y);
                float pattern = abs(xStep - yStep);

                fixed3 color = lerp(black, white, pattern);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
