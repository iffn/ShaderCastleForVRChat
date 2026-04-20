Shader "ShaderCastle/Tutorials/Basics/colororPicker"
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

            // Values in properties need to be readded here
            float _red;
            float _green;
            float _blue;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // Fragment function
            half4 frag () : SV_Target {
                half3 color = half3(_red, _green, _blue);
                return half4(color, 1.0);
            }
            ENDCG
        }
    }
}
