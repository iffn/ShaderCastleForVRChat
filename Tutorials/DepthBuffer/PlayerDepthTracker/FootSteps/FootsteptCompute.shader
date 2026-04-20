Shader "iffnsShaders/Tutorials/DepthBuffer/FootstepCompute"
{
    Properties
    {
        _depthTexture("Depth texture", 2D) = "white" {}
        _depthCenterToCenterOffsetAndScale ("Depth center to center offset and scale", Vector) = (0.0, 0.0, 1.0, 1.0)
        _nearClipDistance("Near clip distance", float) = -1.0
        _farClipDistance("Far clip distance", float) = 1.0
        _footstepColor ("Footstep color", color) = (1.0, 1.0, 1.0, 1.0)
        _baseColor ("Base color", color) = (1.0, 1.0, 1.0, 1.0)
        _fade("Fade", float) = 0.01
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    
    #define currentTexture(U) tex2D(_SelfTexture2D, U)

    sampler2D _depthTexture;

    float pixelWidthU;
    float pixelWidthV;
    half4 _footstepColor;
    half4 _baseColor;
    float4 _depthCenterToCenterOffsetAndScale;
    float _nearClipDistance;
    float _farClipDistance;
    float _fade;
    
    float InverseLerp (float a, float b, float x) {
        return (x - a) / (b - a);
    }

    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;
        float2 uvCenterRender = uv + 0.5;
        half3 currentColor = currentTexture(uv);
        currentColor = lerp(currentColor, _baseColor, _fade);

        float2 uvDepth = uv - _depthCenterToCenterOffsetAndScale.xy;
        uvDepth.y = 1 - uvDepth.y;
        float depthValueRaw = tex2D(_depthTexture, uvDepth).r;
        float depthDistance = lerp(_farClipDistance, _nearClipDistance, depthValueRaw);
        float footstepPaint = step(depthDistance, 0.02);

        half3 color = lerp(currentColor, _footstepColor.rgb, footstepPaint);

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