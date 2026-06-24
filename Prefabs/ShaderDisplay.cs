#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using VRC.SDK3.Editor;
using UnityEditor.SceneManagement;
using UnityEngine.Tilemaps;

[CustomEditor(typeof(ShaderDisplay))]
public class ShaderDisplayEditor : Editor
{
    ShaderDisplay linkedDisplay => (ShaderDisplay)target;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Get"))
        {
            linkedDisplay.GetData();
        }

        if (GUILayout.Button("Set"))
        {
            linkedDisplay.SetData();
        }

        if (GUILayout.Button("Set all"))
        {
            PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();

            ShaderDisplay[] allShaderDisplays;

            if (currentStage == null)
            {
                allShaderDisplays = Object.FindObjectsByType<ShaderDisplay>(FindObjectsSortMode.None);
            }
            else
            {
                GameObject prefabRoot = currentStage.prefabContentsRoot;
                allShaderDisplays = prefabRoot.GetComponentsInChildren<ShaderDisplay>(true);
            }

            foreach (ShaderDisplay display in allShaderDisplays)
            {
                display.SetData();
            }
        }

        if (GUILayout.Button("Get all"))
        {
            PrefabStage currentStage = PrefabStageUtility.GetCurrentPrefabStage();

            ShaderDisplay[] allShaderDisplays;

            if (currentStage == null)
            {
                allShaderDisplays = Object.FindObjectsByType<ShaderDisplay>(FindObjectsSortMode.None);
            }
            else
            {
                GameObject prefabRoot = currentStage.prefabContentsRoot;
                allShaderDisplays = prefabRoot.GetComponentsInChildren<ShaderDisplay>(true);
            }

            foreach (ShaderDisplay display in allShaderDisplays)
            {
                display.GetData();
            }
        }
    }
}

public class ShaderDisplay : MonoBehaviour
{
    [Header("References")]
    [SerializeField] TMP_Text titleElement;
    [SerializeField] UIInterface linkedInterface;
    [SerializeField] MeshRenderer linkedMeshRenderer;

    [Header("Values")]
    [SerializeField] string title;
    [SerializeField] [TextArea(3, 10)] string description;
    [SerializeField] Material linkedMaterial;

    public void GetData()
    {
        if (title.Equals("Title")||title.Length == 0)
            title = titleElement.text;
        title = title.Replace("\r", "").Replace("\n", " ");
        description = linkedInterface.Description;
        if(linkedMeshRenderer)
            linkedMaterial = linkedMeshRenderer.sharedMaterial;
        Undo.RegisterCompleteObjectUndo(this, "Got data");
        EditorUtility.SetDirty(this);
    }

    public void SetData()
    {
        titleElement.text = title;
        linkedInterface.Description = description;
        if(linkedMeshRenderer)
            linkedMeshRenderer.sharedMaterial = linkedMaterial;
        Undo.RegisterCompleteObjectUndo(this, "Set data");
        EditorUtility.SetDirty(gameObject);
    }

}
#endif