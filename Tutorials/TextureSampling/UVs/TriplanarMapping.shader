Shader "ShaderCastle/Tutorials/TextureSampling/TriplanarMapping"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Sharpness ("Sharpness", Range(1, 64)) = 2.0
        _MainTexScale ("Texture Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Sharpness;
            float _MainTexScale;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                o.normal = v.normal;
                return o;
            }

            half3 triplanarColor(float3 pos, float3 normal) {
                float3 weights = abs(normal);
                weights = pow(weights, _Sharpness);
                weights /= (weights.x + weights.y + weights.z);

                float3 direction = sign(normal);

                float2 uvX = float2(pos.z * direction.x, pos.y) * _MainTexScale;
                float2 uvY = float2(pos.x * direction.y, pos.z) * _MainTexScale;
                float2 uvZ = float2(pos.x * -direction.z, pos.y) * _MainTexScale;

                half4 colX = tex2D(_MainTex, uvX);
                half4 colY = tex2D(_MainTex, uvY);
                half4 colZ = tex2D(_MainTex, uvZ);

                half4 finalCol = colX * weights.x + colY * weights.y + colZ * weights.z;
                return finalCol;
            }

            half4 frag (v2f i) : SV_Target {
                half3 color = triplanarColor(i.localPos, i.normal);

                return half4 (color, 1.0);
            }
            ENDCG
        }
    }
}