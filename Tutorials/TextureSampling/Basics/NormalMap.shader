Shader "ShaderCastle/Tutorials/TextureSampling/NormalMap"
{
    Properties
    {
        [Normal] _normalMap ("Normal map", 2D) = "bump" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _normalMap;

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
                half4 packedNormal = tex2D(_normalMap, i.uv);
                float3 tangentNormal = UnpackNormal(packedNormal); // Unity macro to correctly handle the decompression this version of Unity uses
                
                return fixed4(tangentNormal, 1.0);
            }
            ENDCG
        }
    }
}
