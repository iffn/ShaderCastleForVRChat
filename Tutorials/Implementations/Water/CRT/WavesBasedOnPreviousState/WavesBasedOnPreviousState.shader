Shader "ShaderCastle/Tutorials/CustomRenderTexture/GameOfLifeCompute"
{
    Properties
    {
        _originalTexture("Original texture", 2D) = "black" {}
        _waveSpeed("Wave speed", float) = 0.2
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    
    #define currentTexture(U) tex2D(_SelfTexture2D, U)

    sampler2D _paintMask;
    float _waveSpeed;

    /*
        Color channel states:
        - r = Currnet state
        - g = Previous state
        - b = Unused
        - a = Unused
    */

    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        float du = 1.0 / _CustomRenderTextureWidth;
        float dv = 1.0 / _CustomRenderTextureHeight;
        float4 duv = float4(du, dv, -du ,0);
        
        float4 center = currentTexture(uv); 

        float4 up = currentTexture(uv + duv.wy);
        float4 down = currentTexture(uv - duv.wy);
        float4 left = currentTexture(uv + duv.xw);
        float4 right = currentTexture(uv - duv.xw);

        float laplacianWeightedSum = up.r + down.r + left.r + right.r - 4.0 * center.r;

        float nextAmplitude = 2.0 * center.r - center.g + _waveSpeed * laplacianWeightedSum;

        return float4(nextAmplitude, center.r, 0.0, 0.0);
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