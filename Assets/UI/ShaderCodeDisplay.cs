#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ShaderCodeDisplay))]
public class UpdateCodeDisplayEditor : Editor
{
    ShaderCodeDisplay linkedShaderCodeDisplay => (ShaderCodeDisplay)target;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Update code display"))
        {
            linkedShaderCodeDisplay.UpdateCodeDisplay();
        }

        if (GUILayout.Button("Update all code displays in scene"))
        {
            ShaderCodeDisplay[] displays = Object.FindObjectsByType<ShaderCodeDisplay>(FindObjectsInactive.Include, FindObjectsSortMode.None);

            foreach(ShaderCodeDisplay display in displays)
            {
                display.UpdateCodeDisplay();
            }
        }
    }
}

public class ShaderCodeDisplay : MonoBehaviour
{
    [SerializeField] MeshRenderer linkedMeshRenderer;
    [SerializeField] TMPro.TMP_InputField linkedCodeDisplay;

    string GetShaderCodeFromMaterial(Material linkedMaterial)
    {
        string returnString = "";

        if (linkedMaterial == null || linkedMaterial.shader == null)
        {
            Debug.LogWarning("GetShaderCodeFromMaterial: Material or Shader is null.");
            return returnString;
        }

        string shaderPath = AssetDatabase.GetAssetPath(linkedMaterial.shader);

        if (string.IsNullOrEmpty(shaderPath) || !File.Exists(shaderPath))
        {
            Debug.LogWarning($"Shader '{linkedMaterial.shader.name}' is likely a built-in Unity shader and does not exist as a loose asset file in the project.");
            return returnString;
        }

        try
        {
            returnString = File.ReadAllText(shaderPath);
        }
        catch (System.Exception e)
        {
            Debug.LogError($"Failed to read shader file at {shaderPath}: {e.Message}");
        }

        return returnString;
    }

    public void UpdateCodeDisplay()
    {
        if(linkedMeshRenderer == null || linkedCodeDisplay == null)
            return;

        // Update shader code
        Material currentMaterial = linkedMeshRenderer.sharedMaterial;
        string codeDisplay = GetShaderCodeFromMaterial(currentMaterial);
        linkedCodeDisplay.text = codeDisplay;
        
        EditorUtility.SetDirty(linkedCodeDisplay);
    }
}

#endif