#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Linq;

[CustomEditor(typeof(ShaderCodeDisplayFromMaterial))]
public class ShaderCodeDisplayFromMaterialEditor : UpdateCodeDisplayEditor
{
    
}

public class ShaderCodeDisplayFromMaterial : ShaderCodeDisplay
{
    [SerializeField] Material linkedMaterial;

    public override void UpdateCodeDisplay()
    {
        if(linkedMaterial == null)
            return;

        UpdateCodeDisplayFromMaterial(linkedMaterial);
    }
}

#endif
