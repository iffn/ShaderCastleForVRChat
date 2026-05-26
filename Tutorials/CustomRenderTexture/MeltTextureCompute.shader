Shader "ShaderCastle/Tutorials/CustomRenderTexture/MeltTextureCompute"
{
    Properties
    {
        _originalTexture("Original texture", 2D) = "black" {}
        _updateStep("Update step", float) = 0.5
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    
    #define currentTexture(U) tex2D(_SelfTexture2D, U)

    sampler2D _paintMask;
    float _updateStep;

    fixed4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        float du = 1.0 / _CustomRenderTextureWidth;
        float dv = 1.0 / _CustomRenderTextureHeight;
        float4 duv = float4(du, dv, 0 ,0);
        
        float4 cell = currentTexture(uv); 
        float4 cellUp = currentTexture(uv + duv.wy);
        float4 cellDown = currentTexture(uv - duv.wy);
        float4 cellRight = currentTexture(uv + duv.xw);
        float4 cellLeft = currentTexture(uv - duv.xw);
        
        fixed4 color = lerp(cell, cellUp, _updateStep);

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