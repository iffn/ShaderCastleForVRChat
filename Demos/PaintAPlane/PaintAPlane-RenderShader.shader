Shader "ShaderCastle/Demos/PaintAPlane/PaintAPlane-RenderTexture"
{
    Properties
    {
        _paintMask("Paint mask", 2D) = "black" {}
        _paintColor ("Paint color", color) = (1.0, 1.0, 1.0, 1.0)
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    
    #define currentTexture(U) tex2D(_SelfTexture2D, U)

    sampler2D _paintMask;

    float pixelWidthU;
    float pixelWidthV;
    fixed4 _paintColor;
    

    fixed4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        fixed4 currentColor = currentTexture(uv);
        float paintMask = step(0.1, tex2D(_paintMask, uv).r);

        fixed4 color = lerp(currentColor, _paintColor.rgba, paintMask);

        return saturate(color);
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