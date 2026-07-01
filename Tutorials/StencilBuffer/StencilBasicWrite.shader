Shader "ShaderCastle/Tutorials/Stencil/StencilBasicWrite"
{
    Properties
	{
		_mask ("Write mask", Integer) = 1
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1" } // Runs before geometry

        ColorMask 0
        ZWrite Off

        Pass {
            Stencil {
                Ref [_mask] // What values are being written,             with 1: xxxx xxx1 (x doesn't matter because of the mask)
                WriteMask 255 // Only the last bit should be changed, with 1: 0000 0001
                Comp Always
                Pass Replace
            }
        }
    }
}