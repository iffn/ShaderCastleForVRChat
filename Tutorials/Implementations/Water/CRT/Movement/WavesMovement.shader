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
        
        float4 center = currentTexture(uv + duv.xw); 

        float4 up = currentTexture(uv + duv.xy);
        float4 down = currentTexture(uv - duv.zy);
        float4 left = currentTexture(uv + duv.ww);
        float4 right = currentTexture(uv + 2*duv.xw);

        float laplacianWeightedSum = up.r + down.r + left.r + right.r - 4.0 * center.r;

        float nextAmplitude = 2.0 * center.r - center.g + _waveSpeed * laplacianWeightedSum;

        // Edge absorbtion
        if (uv.x <= du || uv.x >= 1.0 - du || 
            uv.y <= dv || uv.y >= 1.0 - dv) 
        {
            float coeff = (_waveSpeed - 1.0) / (_waveSpeed + 1.0);
            
            float currentInner;
            if      (uv.x <= du)         currentInner = right.r;
            else if (uv.x >= 1.0 - du)   currentInner = left.r;
            else if (uv.y <= dv)         currentInner = down.r;
            else                         currentInner = up.r;

            nextAmplitude = currentInner + (nextAmplitude - center.r) * coeff;
        }

        float2 circleCenter = float2(0.8, 0.5 + sin(_Time.y) * 0.1);
        float radiusInUV = du; // 1 pixel width in UV space

        float d = distance(uv, circleCenter);
        float circle = step(d, radiusInUV);

        return float4(nextAmplitude + circle, center.r + circle, 0.0, 0.0);
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