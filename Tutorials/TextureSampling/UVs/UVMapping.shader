Shader "ShaderCastle/Tutorials/TextureSampling/UVMapping"
{
    Properties
    {
        _albedo ("Albedo", 2D) = "white" {}
        _modelScale ("Model scale", float) = 1.0
    }
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _albedo;
            float _modelScale;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            v2g vert (appdata v) {
                v2g o;
                float4 pos = v.vertex;
                float2 uv = v.uv - float2(0.5, 0.5);
                float4 uvPos = float4(uv.x, uv.y, 0.0, 0.0);
                
                float lerpValue = sin(_Time.y) * 0.5 + 0.5;
                
                float4 finalPos = lerp(pos * _modelScale, uvPos, lerpValue);

                o.pos = UnityObjectToClipPos(finalPos);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Geometry to fragment transfer data
            struct g2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 barycentric : TEXCOORD1;
            };
            
            // Geometry function
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
                g2f o;

                o.pos = IN[0].pos;
                o.uv = IN[0].uv;
                o.barycentric = float3(1.0, 0.0, 0.0);
                triStream.Append(o);
                
                o.pos = IN[1].pos;
                o.uv = IN[1].uv;
                o.barycentric = float3(0.0, 1.0, 0.0);
                triStream.Append(o);

                o.pos = IN[2].pos;
                o.uv = IN[2].uv;
                o.barycentric = float3(0.0, 0.0, 1.0);
                triStream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target {
                float closest = min(i.barycentric.x, min(i.barycentric.y, i.barycentric.z));
                float WireframeWith = 0.02;
                float frame = step(closest, WireframeWith);

                half3 frameColor = half3(0.0, 0.0, 0.0); // Black
                half3 albedo = tex2D(_albedo, i.uv);
                half3 color = half3(1.0, 0.0, 0.0); // Red

                color = lerp(color, frameColor, frame);

                return float4(i.barycentric.xyz, 1.0);
            }
            ENDCG
        }
    }
}
