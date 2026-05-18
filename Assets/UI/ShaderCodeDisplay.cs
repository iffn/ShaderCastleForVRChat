#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using TMPro;

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
    [SerializeField] TMP_InputField linkedCopyCodeInput;
    [SerializeField] TMP_Text linkedColoredCodeDisplay;

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
        if(linkedMeshRenderer == null || linkedCopyCodeInput == null)
            return;

        // Update shader code
        Material currentMaterial = linkedMeshRenderer.sharedMaterial;
        string codeDisplay = GetShaderCodeFromMaterial(currentMaterial);

        string coloredCode = colorShaderCode(codeDisplay);

        linkedCopyCodeInput.text = codeDisplay;
        linkedColoredCodeDisplay.text = coloredCode;
        
        EditorUtility.SetDirty(linkedCopyCodeInput);
        EditorUtility.SetDirty(linkedColoredCodeDisplay);
    }

    public static string colorShaderCode(string code)
    {
        // Hardcoded color hex codes
        string keywordColor = "#569CD6"; // Blue
        string stringColor = "#D69D85";  // Orange
        string commentColor = "#57A64A"; // Green

        // Hardcoded regex patterns
        string stringPattern = @"(""[^""\\]*(?:\\.[^""\\]*)*"")";
        string keywordPattern = @"(?<!<[^>]*)\b(Shader|SubShader|Pass|CGPROGRAM|ENDCG|vertex|fragment|float|fixed|v2f|appdata|Properties|sampler2D|struct)\b(?![^>]*>)";
        string commentPattern = @"(//.*)";

        // Clean out any existing color tags first to avoid nesting issues
        string coloredCode = System.Text.RegularExpressions.Regex.Replace(code, @"<color=#[A-Fa-f0-9]+>", "");
        coloredCode = coloredCode.Replace("</color>", "");

        // 1. Colorize Strings
        coloredCode = System.Text.RegularExpressions.Regex.Replace(coloredCode, stringPattern, $"<color={stringColor}>$1</color>");

        // 2. Colorize Keywords
        coloredCode = System.Text.RegularExpressions.Regex.Replace(coloredCode, keywordPattern, $"<color={keywordColor}>$1</color>");

        // 3. Colorize Comments last and strip nested tags inside them
        coloredCode = System.Text.RegularExpressions.Regex.Replace(coloredCode, commentPattern, m => {
            string cleanComment = System.Text.RegularExpressions.Regex.Replace(m.Value, @"<color=#[A-Fa-f0-9]+>", "");
            cleanComment = cleanComment.Replace("</color>", "");
            return $"<color={commentColor}>{cleanComment}</color>";
        });

        return coloredCode;
    }
}

#endif