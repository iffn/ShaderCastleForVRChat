Shader "ShaderCastle/Basics/ColorPicker"
{
    Properties
    {
        _red ("Red", float) = 1.0
        _green ("Green", float) = 0.0
        _blue ("Blue", float) = 0.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _red;
            float _green;
            float _blue;

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
            fixed4 frag () : SV_Target {
                fixed4 col = fixed4(_red, _green, _blue, 1);
                return col; // Red
            }
            ENDCG
        }
    }
}
