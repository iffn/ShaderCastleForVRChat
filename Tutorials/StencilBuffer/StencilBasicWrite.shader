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
                WriteMask 255 // Binary mask which pixels should be written. With 255: 1111 1111
                Comp Always
                Pass Replace
            }
        }
    }
}