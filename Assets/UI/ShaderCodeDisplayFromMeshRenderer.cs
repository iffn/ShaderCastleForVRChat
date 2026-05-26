#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Linq;

[CustomEditor(typeof(ShaderCodeDisplayFromMeshRenderer))]
public class ShaderCodeDisplayFromMeshRendererEditor : UpdateCodeDisplayEditor
{
    
}

public class ShaderCodeDisplayFromMeshRenderer : ShaderCodeDisplay
{
    [SerializeField] MeshRenderer linkedMeshRenderer;

    public override void UpdateCodeDisplay()
    {
        if(linkedMeshRenderer == null)
            return;

        UpdateCodeDisplayFromMaterial(linkedMeshRenderer.sharedMaterial);
    }
}

#endif