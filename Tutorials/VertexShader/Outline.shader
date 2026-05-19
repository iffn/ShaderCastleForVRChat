Shader "ShaderCastle/Tutorials/VertexShader/Outline"
{
    Properties
    {
        _outlineThickness ("Outline thickness", float) = 0.02
        _outlineColor ("Outline color", color) = (0,0,0,1)
    }
    SubShader
    {
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _outlineThickness;
            half3 _outlineColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                v.vertex.xyz += normalize(v.normal) * _outlineThickness;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // Fragment function
            half4 frag () : SV_Target {
                return half4(_outlineColor, 1.0);
            }
            ENDCG
        }
    }
}
