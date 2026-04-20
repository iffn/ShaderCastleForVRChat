Shader "ShaderCastle/Tutorials/Stencil/StencilBasicWrite"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1" } // Runs before geometry

        ColorMask 0
        ZWrite Off

        Pass {
            Stencil {
                Ref 1 // What values are being written:             xxxx xxx1 (x doesn't matter because of the mask)
                WriteMask 1 // Only the last bit should be changed: 0000 0001
                Comp Always
                Pass Replace
            }
        }
    }
}