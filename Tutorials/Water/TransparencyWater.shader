Shader "ShaderCastle/Water/TransparencyWater"
{
    Properties
    {
        _albedo ("Albedo", color) = (0.2, 0.2, 1.0, 0.3)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _albedo;

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
                return _albedo;
            }
            ENDCG
        }
    }
}
