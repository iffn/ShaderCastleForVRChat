Shader "ShaderCastle/Tutorials/MathFunctions/MandelbrotFunction"
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

            float _patternAngle;
            float4 _base;
            float4 _shape;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                float3 localPos = i.localPos;

                float angleRad = atan2(localPos.y, localPos.x);
                float angleDeg = angleRad * 57.29578 + 180;
                angleDeg = angleDeg % _patternAngle;

                float lerpValue = step(_patternAngle * 0.1, angleDeg);

                float3 color = lerp(_base, _shape, lerpValue);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
