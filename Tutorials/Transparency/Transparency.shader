Shader "ShaderCastle/Transparency/Transparency"
{
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        
        Pass
        {

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert // The vertex function is called vert
            #pragma fragment frag // The fragment funciton is called frag

            // Mesh to vertex transfer data
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex to fragment transfer data
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex function
            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // Basic object to clip space transformation
                o.uv = v.uv;
                return o;
            }

            // Fragment function
            fixed4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;

                float distanceToCenter = length(uv - float2(0.5, 0.5));

                float alpha = saturate(1 - distanceToCenter * 2.0);

                fixed3 color = fixed3(1.0, 1.0, 1.0);
                return fixed4(color, alpha);
            }
            ENDCG
        }
    }
}
