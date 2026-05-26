Shader "ShaderCastle/Tutorials/CustomRenderTexture/GameOfLifeCompute"
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
        float4 duv = float4(du, dv, -du ,0);
        
        float4 cell = currentTexture(uv); 

        float4 cellUp = currentTexture(uv + duv.wy);
        float4 cellDown = currentTexture(uv - duv.wy);
        float4 cellRight = currentTexture(uv + duv.xw);
        float4 cellLeft = currentTexture(uv - duv.xw);

        float cellUpRight   = currentTexture(uv + duv.xy);
        float cellUpLeft    = currentTexture(uv + duv.zy);
        float cellDownRight = currentTexture(uv - duv.zy);
        float cellDownLeft  = currentTexture(uv - duv.xy);

        float neighborsAlive = cellUp + cellDown + cellRight + cellLeft + cellUpRight + cellUpLeft + cellDownRight + cellDownLeft;

        float willBeAlive = 0.0;
        if(neighborsAlive == 3.0 || (neighborsAlive == 2.0 && cell.r == 1.0))
            willBeAlive = 1.0;
        
        float4 deadColor = float4(0,0,0,0);
        float4 aliveColor = float4(1,1,1,1);
        
        fixed4 color = lerp(deadColor, aliveColor, willBeAlive);

        return color;
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