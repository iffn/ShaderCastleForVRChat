Shader "iffnsShaders/Tutorials/DepthBuffer/PaintCompute"
{
    Properties
    {
        _depthTexture("Depth texture", 2D) = "white" {}
        _paint_color ("Paint color", color) = (1.0, 1.0, 1.0, 1.0)
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    
    #define currentTexture(U) tex2D(_SelfTexture2D, U)

    sampler2D _depthTexture;

    float pixelWidthU;
    float pixelWidthV;
    half4 _paint_color;
    

    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        half3 currentColor = currentTexture(uv);
        float2 uvDepth = uv;
        uvDepth.x = uvDepth.x;
        float depthValueRaw = tex2D(_depthTexture, uvDepth).r;

        half3 color = lerp(currentColor, _paint_color.rgb, depthValueRaw);

        return float4(color, 1.0);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }
    }
}